module PuntoPagosRails
  class TransactionService < Struct.new(:resource_id)
    attr_accessor :process_url

    SUCCESS_CODE = "99"
    ERROR_CODE = "00"

    def create
      transaction = resource.transactions.create!

      request = PuntoPagos::Request.new
      response = request.create(transaction.id.to_s, transaction.amount_to_s, nil)

      if !response.success?
        resource.errors.add :base, I18n.t("punto_pagos_rails.errors.invalid_puntopagos_response")
        return false
      end

      init_transaction(transaction, response.get_token).tap do |transaction_result|
        self.process_url = response.payment_process_url if transaction_result
      end
    end

    def self.notificate(params, headers)
      notification = PuntoPagos::Notification.new
      tken = params[:token]
      err = params[:error]

      if notification.valid?(headers, params)
        PuntoPagosRails.resource_class.notify(@resource, :success)
        respond_success(tken)
      else
        PuntoPagosRails.resource_class.notify(@resource, :error)
        respond_error(tken, err)
      end
    end

    def error
      resource.errors.messages[:base].first
    end

  private

    def self.processing_transaction(token)
      transaction = Transaction.find_by_token(token)
      return unless transaction
      return unless transaction.pending?
      transaction
    end

    def self.respond_success(token)
      transaction = processing_transaction(token)
      return if transaction.nil?
      transaction.complete
      transaction.save
      { respuesta: SUCCESS_CODE, token: token }
    end

    def self.respond_error(token, error)
      transaction = processing_transaction(token)
      return if transaction.nil?
      transaction.reject_with(error)
      transaction.save
      { respuesta: ERROR_CODE, error: error, token: token }
    end

    def init_transaction(transaction, token)
      if token.blank?
        resource.errors.add :base, I18n.t("punto_pagos_rails.errors.invalid_returned_puntopagos_token")
        return false
      end

      if token_repeated?(token)
        resource.errors.add :base, I18n.t("punto_pagos_rails.errors.repeated_token_given")
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
