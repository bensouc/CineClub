Rails.application.routes.draw do
  devise_for :users
  root to: "events#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :events, only: [:index, :show, :update, :new, :create, :destroy] do
    post 'choices/:id', to: 'choices#vote', as: 'vote'
    delete "choices/:id", to: 'choices#unvote', as: 'unvote'
  end
  post '/events/:id', to: 'events#add_movie', as: 'add_movie'

  resources :choices, only: [:destroy]


end
