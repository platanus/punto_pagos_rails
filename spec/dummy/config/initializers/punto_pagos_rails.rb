PuntoPagosRails.setup do |config|
  config.resource_class_name = 'Ticket'
  config.punto_pagos = {
    key: ENV["PUNTO_PAGOS_KEY"],
    secret: ENV["PUNTO_PAGOS_SECRET"],
    env: ENV["PUNTO_PAGOS_ENV"]
  }
end
