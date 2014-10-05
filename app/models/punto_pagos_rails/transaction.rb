module PuntoPagosRails
  class Transaction < ActiveRecord::Base
    belongs_to :resource, class_name: PuntoPagosRails.resource_class
  end
end
