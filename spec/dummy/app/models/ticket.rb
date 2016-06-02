class Ticket < ActiveRecord::Base
  include PuntoPagosRails::Payable
end
