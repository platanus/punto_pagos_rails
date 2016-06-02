require "punto_pagos_rails/engine"
require "punto_pagos_rails/resource_extension"
require "punto_pagos_rails/transaction_service"

module PuntoPagosRails
  extend self

  attr_accessor :payable_resources

  attr_accessor :resource_class_name # TODO: deprecate

  def resource_class  # TODO: deprecate
    resource_class_name.constantize
  end

  def setup
    yield self
    require "puntopagos"
  end
end
