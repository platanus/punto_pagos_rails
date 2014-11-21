module PuntoPagosRails
  class Transaction < ActiveRecord::Base
    belongs_to :resource, class_name: PuntoPagosRails.resource_class

    delegate :amount, :to => :resource

    def amount_to_s
      "%0.2f" % amount.to_i
    end
    
  end
end
