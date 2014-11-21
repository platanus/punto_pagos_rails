require "puntopagos"
require "punto_pagos_rails/engine"
require "punto_pagos_rails/resource_extension"
require "punto_pagos_rails/transaction_service"

module PuntoPagosRails
  mattr_accessor :resource_class_name

  def self.resource_class
    resource_class_name.constantize
  end

  def self.setup
    yield self
  end
end
