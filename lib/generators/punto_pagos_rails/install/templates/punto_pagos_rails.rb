PuntoPagosRails.setup do |config|
  config.resource_class_name = '<%= name.classify %>'
  config.punto_pagos = {
    key: "YOUR KEY",
    secret: "YOUR SECRET",
    env: "sandbox or production"
  }
end
