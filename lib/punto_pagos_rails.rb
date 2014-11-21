require "punto_pagos_rails/engine"
require "punto_pagos_rails/resource_extension"
require "punto_pagos_rails/transaction_service"

module PuntoPagosRails
  extend self

  attr_accessor :resource_class_name, :punto_pagos

  def resource_class
    resource_class_name.constantize
  end

  def punto_pagos
    @punto_pagos ||= {}
  end

  def setup
    yield self
    require "puntopagos"
    load_puntopagos_configuration
  end

  def load_puntopagos_configuration
    PuntoPagos::Config.class_eval do
      def puntopagos_key
        @puntopagos_key ||= PuntoPagosRails.punto_pagos[:key]
      end

      def puntopagos_secret
        @puntopagos_secret ||= PuntoPagosRails.punto_pagos[:secret]
      end

      def puntopagos_base_url
        @puntopagos_base_url ||= PuntoPagos::Config::PUNTOPAGOS_BASE_URL[PuntoPagosRails.punto_pagos[:env]]
      end
    end
  end
end
