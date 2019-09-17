# frozen_string_literal: true

Rails.application.routes.draw do
  get 'admin' => 'admin#index'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  resources :users

  resources :products do
    get :who_bought, on: :member
  end

  scope '(:locale)' do
    resources :orders
    resources :line_items
    resources :carts
    get 'store/index'
    post 'store/index'
    root to: 'store#index', as: 'store'
  end
end
