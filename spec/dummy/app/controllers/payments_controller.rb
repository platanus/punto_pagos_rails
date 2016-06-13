class PaymentsController < ApplicationController
  def create
    @ticket = Ticket.create!(create_params)
    srv = PuntoPagosRails::TransactionService.new(@ticket)
    srv.create ? redirect_to(srv.process_url) : render(:error)
  end

  def notification
    PuntoPagosRails::TransactionService.complete(params)
    head(200)
  end

  def success
    @ticket = PuntoPagosRails::TransactionService.ticket_by_token(params)
  end

  def error
    @ticket = PuntoPagosRails::TransactionService.failed_ticket_by_token(params)
  end

  private

  def create_params
    params.require(:ticket).permit(:amount)
  end
end
