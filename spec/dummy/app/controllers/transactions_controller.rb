class TransactionsController < ApplicationController
  def create
    @ticket = Ticket.create!(create_params)
    srv = PuntoPagosRails::TransactionService.new(@ticket)

    if srv.create
      redirect_to(srv.process_url)
    else
      render_payment_error_view(srv.error)
    end
  end

  def notification
    @ticket = PuntoPagosRails::TransactionService.notificate(params, request.headers)
    render(json: response)
  end

  def success
    @ticket = ticket_by_token
  end

  def error
    @ticket = ticket_by_token
    render_payment_error_view(I18n.t("punto_pagos_rails.errors.invalid_puntopagos_payment"))
  end

  private

  def render_payment_error_view(error_message)
    render(:error, locals: { error_message: error_message })
  end

  def ticket_by_token
    @ticket ||= Ticket.by_token(params[:token])
  end

  def create_params
    params.require(:ticket).permit(:amount)
  end
end
