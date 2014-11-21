Rails.application.routes.draw do

  mount PuntoPagosRails::Engine => "/punto_pagos_rails"

  root to: 'home#index'
end
