require "punto_pagos_rails/engine"

module PuntoPagosRails
  mattr_accessor :resource_class

  def self.setup
    yield self
  end
end
