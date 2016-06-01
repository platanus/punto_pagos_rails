module PuntoPagosRails
  class TransactionService
    attr_accessor :process_url
    attr_reader :resource_id

    SUCCESS_CODE = "99"
    ERROR_CODE = "00"

    def initialize(resource_id)
      @resource_id = resource_id
    end

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
        respond_success(tken)
      else
        respond_error(tken, err)
      end
    end

    def self.validate(token, transaction)
      status = PuntoPagos::Status.new
      status.check(token, transaction.id.to_s, transaction.amount_to_s)

      if status.valid?
        respond_success(token)
      else
        respond_error(token, status.error)
      end
    end

    def error
      resource.errors.messages[:base].first
    end

    def self.processing_transaction(token)
      transaction = Transaction.find_by_token(token)
      return unless transaction
      return unless transaction.pending?
      transaction
    end

    def self.respond_success(token)
      transaction = processing_transaction(token)
      return if transaction.nil?
      transaction.resource.run_callbacks :payment_success do
        transaction.complete
        transaction.save
      end
      { respuesta: SUCCESS_CODE, token: token }
    end

    def self.respond_error(token, error)
      transaction = processing_transaction(token)
      return if transaction.nil?
      transaction.resource.run_callbacks :payment_error do
        transaction.reject_with(error)
        transaction.save
      end
      { respuesta: ERROR_CODE, error: error, token: token }
    end

    private

    def init_transaction(transaction, token)
      if token.blank?
        resource.errors.add(:base,
          I18n.t("punto_pagos_rails.errors.invalid_returned_puntopagos_token"))
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
