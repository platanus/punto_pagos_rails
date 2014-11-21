Rails.application.routes.draw do

  mount PuntoPagosRails::Engine => "/"

  root to: 'home#index'
end
