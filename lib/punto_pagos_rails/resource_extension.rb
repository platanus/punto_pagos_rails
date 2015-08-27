require 'active_support/concern'

module PuntoPagosRails
  module ResourceExtension
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      define_callbacks :payment_error
      define_callbacks :payment_success

      has_many :transactions, class_name: 'PuntoPagosRails::Transaction', foreign_key: :resource_id

      def paid?
        return false unless self.transactions.any?
        self.transactions.last.completed?
      end

    end

    module ClassMethods
      # TODO
    end
  end
end
