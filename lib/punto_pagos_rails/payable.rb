require "active_support/concern"

module PuntoPagosRails
  module Payable
    extend ActiveSupport::Concern

    included do
      has_many :transactions, as: :payable, class_name: "PuntoPagosRails::Transaction"

      def paid?
        return false unless transactions.any?
        transactions.last.completed?
      end
    end

    module ClassMethods
      def by_token(token)
        transaction = Transaction.find_by(token: token)
        transaction.try(:resource)
      end
    end
  end
end
