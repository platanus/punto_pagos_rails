require 'active_support/concern'

module PuntoPagosRails
  module ResourceExtension
    extend ActiveSupport::Concern

    included do
      has_many :transactions, class_name: 'PuntoPagosRails::Transaction', foreign_key: :resource_id
    end

    module ClassMethods
      # TODO
    end
  end
end