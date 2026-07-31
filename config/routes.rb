Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  root to: "events#index"

  # Private club: accounts are created from an admin-issued link, never from a
  # public sign-up form.
  resources :invitations, only: [:index, :create, :destroy]
  get "rejoindre/:token", to: "invitations#show", as: :join

  # Reveal application health on /up.
  get "up" => "rails/health#show", as: :rails_health_check

  # JSON proxy in front of the TMDB search API, so the API key stays on the server.
  get "movies/search", to: "movies#search", as: :movies_search

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :events do
    # Adding a movie to an event creates a Choice, so it lives with the rest of
    # the Choice lifecycle rather than on EventsController.
    resources :choices, only: [:create]
    post 'choices/:id', to: 'choices#vote', as: 'vote'
    delete "choices/:id", to: 'choices#unvote', as: 'unvote'
  end

  resources :choices, only: [:destroy]
end
