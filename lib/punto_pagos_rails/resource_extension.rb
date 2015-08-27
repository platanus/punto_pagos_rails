require 'active_support/concern'

module PuntoPagosRails
  module ResourceExtension
    extend ActiveSupport::Concern

    included do
      has_many :transactions, class_name: 'PuntoPagosRails::Transaction', foreign_key: :resource_id

      def paid?
        return false unless self.transactions.any?
        self.transactions.last.completed?
      end

    end

    module ClassMethods

      def on_payment_error(&block)
        @payment_error_cb = block
      end

      def on_payment_success(&block)
        @payment_success_cb = block
      end

      def notify(resource, type)
        if type == :error && @payment_error_cb
          resource.instance_exec(&@payment_error_cb)
        end
        if type == :success && @payment_success_cb
          resource.instance_exec(&@payment_success_cb)
        end
      end

    end
  end
end
