FactoryBot.define do
  factory :transaction, class: PuntoPagosRails::Transaction do
    association :payable, factory: :ticket
    token { SecureRandom.hex }
  end
end
