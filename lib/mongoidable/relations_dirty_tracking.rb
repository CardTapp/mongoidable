# frozen_string_literal: true

require "mongoid"
require "active_support/concern"

module Mongoidable
  module RelationsDirtyTracking
    extend ActiveSupport::Concern

    class << self
      DISABLED_KEY = "mongoid/relations_dirty_tracking/disabled"

      # Runs a block without invoking relations dirty tracking on the current thread.
      # Returns the block return value.
      def disable
        thread_store[DISABLED_KEY] = true
        yield
      ensure
        thread_store[DISABLED_KEY] = false
      end

      # Returns whether relations dirty tracking is enabled on the current thread.
      def enabled?
        !thread_store[DISABLED_KEY]
      end

      protected

      def thread_store
        defined?(RequestStore) ? RequestStore.store : Thread.current
      end
    end

    module ClassMethods
      def relations_dirty_tracking(options = {})
        relations_dirty_tracking_options[:only]   += [options[:only]   || []].flatten.map(&:to_s)
        relations_dirty_tracking_options[:except] += [options[:except] || []].flatten.map(&:to_s)
      end

      def track_relation?(rel_name)
        rel_name = rel_name.to_s
        options = relations_dirty_tracking_options
        to_track = (options[:only].present? && options[:only].include?(rel_name)) ||
          (options[:only].blank? && !options[:except].include?(rel_name))

        trackables = [Mongoid::Relations::Embedded::One,
                      Mongoid::Relations::Embedded::Many,
                      Mongoid::Relations::Referenced::One,
                      Mongoid::Relations::Referenced::Many,
                      Mongoid::Relations::Referenced::ManyToMany]

        to_track && trackables.include?(relations[rel_name].try(:relation))
      end

      def tracked_relations
        @tracked_relations ||= relations.keys.select { |rel_name| track_relation?(rel_name) }
      end
    end

    included do
      after_initialize :store_relations_shadow
      after_save       :store_relations_shadow

      cattr_accessor :relations_dirty_tracking_options
      self.relations_dirty_tracking_options = { only: [], except: ["versions"] }

      def store_relations_shadow
        @relations_shadow = {}
        return if readonly? || !Mongoidable::RelationsDirtyTracking.enabled?

        self.class.tracked_relations.each do |rel_name|
          @relations_shadow[rel_name] = tracked_relation_attributes(rel_name)
        end
      end

      def relation_changes
        return {} if readonly? || !Mongoidable::RelationsDirtyTracking.enabled?

        changes = {}
        @relations_shadow.each_pair do |rel_name, shadow_values|
          current_values = tracked_relation_attributes(rel_name)
          changes[rel_name] = [shadow_values, current_values] if current_values != shadow_values
        end
        changes
      end

      def relations_changed?
        !relation_changes.empty?
      end

      def changed_with_relations?
        changed? || relations_changed?
      end

      def changes_with_relations
        (changes || {}).merge(relation_changes)
      end

      def tracked_relation_attributes(rel_name)
        rel_name = rel_name.to_s
        meta = relations[rel_name]
        return nil unless meta

        relation_key = associations[rel_name]
        case meta.relation.to_s
          when Mongoid::Relations::Embedded::One.to_s
            val = send(rel_name)
            val && val.attributes.clone.delete_if { |key, _| key == "updated_at" }
          when Mongoid::Relations::Embedded::Many.to_s
            val = send(rel_name)
            val && val.map { |child| child.attributes.clone.delete_if { |key, _| key == "updated_at" } }
          when Mongoid::Relations::Referenced::One.to_s
            send(meta.key)
          when Mongoid::Relations::Referenced::Many.to_s
            Array.wrap(send(meta.key))
          when Mongoid::Relations::Referenced::ManyToMany.to_s
            Array.wrap(send(meta.key))
        end
      end
    end
  end
end