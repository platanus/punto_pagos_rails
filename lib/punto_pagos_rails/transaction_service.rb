module PuntoPagosRails
  class TransactionService < Struct.new(:resource_id)
    attr_accessor :process_url

    def create
      transaction = resource.transactions.create!

      request = PuntoPagos::Request.new
      response = request.create(transaction.id.to_s, transaction.amount_to_s, nil)

      if !response.success?
        resource.errors.add :base, :invalid_puntopagos_response
        return false
      end

      init_transaction(transaction, response.get_token).tap do |transaction_result|
        self.process_url = response.payment_process_url if transaction_result
      end
    end

    def error
      resource.errors.messages[:base].first
    end

    private

    def init_transaction(transaction, token)
      if token.blank?
        appointment.errors.add :base, :invalid_returned_puntopagos_token
        return false
      end

      if token_repeated?(token)
        appointment.errors.add :base, :repeated_token_given
        return false
      end

      transaction.update!(token: token, amount: resource.amount)
    end

    def token_repeated?(token)
      Transaction.where(token: token).any?
    end

    def resource
      @resource ||= PuntoPagosRails.resource_class.find(resource_id)
    end
  end
end
