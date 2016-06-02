require "punto_pagos_rails/engine"
require "punto_pagos_rails/payable"
require "punto_pagos_rails/transaction_service"

module PuntoPagosRails
  extend self

  def setup
    yield self
    require "puntopagos"
  end
end
