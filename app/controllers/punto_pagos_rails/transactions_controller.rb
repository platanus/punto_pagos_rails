module PuntoPagosRails
  class TransactionsController < ApplicationController
    def create
      srv = TransactionService.new(resource_id)

      if srv.create
        redirect_to srv.process_url
      else
        @resource = resource_by_id
        if error_url = PuntoPagosRails.error_url
          url = instance_exec(@resource, &error_url)
          redirect_to url
        else
          render_payment_error_view srv.error
        end
      end
    end

    def notification
      response = TransactionService.notificate(params, request.headers)
      render json: response
    end

    def notification_no_ssl
      response = TransactionService.validate(params[:token], transaction)
      head 200
    end

    def success
      @resource = resource_by_token
      if success_url_block = PuntoPagosRails.success_url
        url = instance_exec(@resource, &success_url_block)
        redirect_to url
      end
    end

    def error
      @resource = resource_by_token
      translated_error = I18n.t("punto_pagos_rails.errors.invalid_puntopagos_payment")
      if error_url = PuntoPagosRails.error_url
        url = instance_exec(@resource, translated_error , &error_url)
        redirect_to url
      else
        render_payment_error_view translated_error
      end
    end

    private

    def render_payment_error_view(error_message)
      render 'error', locals: { error_message: error_message }
    end

    def resource_id
      @resource_id ||= begin
        params.require(:resource_id)
        params[:resource_id]
      end
    end

    def transaction
      @transcation ||= Transaction.find_by(token: params[:token])
    end

    def resource_by_token
      transaction.try(:resource)
    end

    def resource_by_id
      PuntoPagosRails.resource_class.find_by(id: params[:resource_id])
    end
  end
end
