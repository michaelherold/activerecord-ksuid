# frozen_string_literal: true

module ActiveRecord
  module KSUID
    # Enables the usage of KSUID types within ActiveRecord when Rails is loaded
    #
    # @api private
    class Railtie < ::Rails::Railtie
      initializer 'ksuid' do
        ActiveSupport.on_load :active_record do
          require 'active_record/ksuid'
          require 'active_record/ksuid/table_definition'
        end
      end
    end
  end
end
