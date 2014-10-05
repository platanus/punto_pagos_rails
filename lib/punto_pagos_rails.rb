require "punto_pagos_rails/engine"
require "punto_pagos_rails/resource_extension"

module PuntoPagosRails
  mattr_accessor :resource_class

  def self.setup
    yield self
  end
end
