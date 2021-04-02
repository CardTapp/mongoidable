# frozen_string_literal: true

ActiveModelSerializers.logger = Rails.logger
ActiveModelSerializers.config.adapter = :json
ActiveModelSerializers.config.serializer_lookup_chain = ActiveModelSerializers::LookupChain::DEFAULT