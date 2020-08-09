Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    resources :customers, only: %i[index show create update destroy]
    resources :orders, only: %i[index show create update destroy]
    resources :products, only: %i[index show create update destroy]
    resources :order_products, only: %i[index show create update destroy]
  end
end
