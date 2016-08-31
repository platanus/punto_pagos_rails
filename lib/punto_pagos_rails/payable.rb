require "active_support/concern"

module PuntoPagosRails
  module Payable
    extend ActiveSupport::Concern
    attr_reader :payment_method

    PAYMENT_STATES = %w{pending completed rejected}

    included do
      extend Enumerize

      has_many :transactions, as: :payable, class_name: "PuntoPagosRails::Transaction"
      enumerize :payment_state, in: PAYMENT_STATES,
                                default: :pending,
                                predicates: true,
                                scope: true,
                                prefix: false

      def paid?
        completed?
      end

      def payment_method=(value)
        value = value.to_i
        @payment_method = value.zero? ? nil : value
      end
    end

    module ClassMethods
      def by_token(token)
        transaction = Transaction.find_by(token: token)
        transaction.try(:payable)
      end
    end
  end
end
