module PuntoPagosRails
  class TransactionsController < ApplicationController
    def create
      srv = TransactionService.new(resource_id)

      if srv.create
        redirect_to srv.process_url
      else
        render_payment_error_view srv.error
      end
    end

    private

    def render_payment_error_view(error_key = nil)
      raise "Error message unspecified" if error_key.nil?

      render error_template, locals: { error_key: error_key }
    end

    def error_template
      'error'
    end

    def resource_id
      @resource_id ||= begin
        params.require(:resource_id)
        params[:resource_id]
      end
    end
  end
end
