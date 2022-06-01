Rails.application.routes.draw do
  devise_for :users
  root to: "events#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :events, only:[:index, :show, :update, :new, :create, :destroy] 
end
