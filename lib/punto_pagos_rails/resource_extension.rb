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
      # TODO
    end
  end
end
