class Ticket < ActiveRecord::Base
  include PuntoPagosRails::ResourceExtension

  attr_reader :message

  set_callback :payment_success, :after do
    @message = "successful payment! #{self.id}"
  end

  set_callback :payment_error, :after do
    @message = "error paying ticket #{self.id}"
  end
end
