PuntoPagosRails.setup do |config|
  config.resource_class_name = 'Ticket'
  config.payable_resources = [:ticket]
end
