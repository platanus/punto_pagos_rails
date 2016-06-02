Rails.application.routes.draw do
  post "transactions/notification", to: "transactions#notification"
  get "transactions/error/:token", to: "transactions#error", as: :transaction_error
  get "transactions/success/:token", to: "transactions#success", as: :transaction_success
  post "transactions/create", to: "transactions#create", as: :transaction_create

  root to: 'home#index'
end
