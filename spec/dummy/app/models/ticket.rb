class Ticket < ActiveRecord::Base
  include PuntoPagosRails::ResourceExtension

  attr_reader :paid

  set_callback :payment_success, :after do
    @paid = true
  end
end
