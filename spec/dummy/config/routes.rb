Rails.application.routes.draw do
  # NO SSL
  get "payments/notification/:token", to: "payments#notification"
  get "payments/error/:token", to: "payments#error", as: :payment_error
  get "payments/success/:token", to: "payments#success", as: :payment_success
  post "payments/create", to: "payments#create", as: :payment_create

  # SSL
  post "transactions/notification", to: "transactions#notification"
  get "transactions/error/:token", to: "transactions#error", as: :transaction_error
  get "transactions/success/:token", to: "transactions#success", as: :transaction_success
  post "transactions/create", to: "transactions#create", as: :transaction_create

  root to: 'home#index'
end
