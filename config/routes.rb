Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  root "home#index"

  # Authentication
  get    "login",    to: "sessions#new",     as: :login
  post   "login",    to: "sessions#create"
  delete "logout",   to: "sessions#destroy", as: :logout
  get    "register", to: "registrations#new", as: :register
  post   "register", to: "registrations#create"
  get    "password/reset",        to: "password_resets#new",    as: :new_password_reset
  post   "password/reset",        to: "password_resets#create", as: :password_reset
  get    "password/reset/:token", to: "password_resets#edit",   as: :edit_password_reset
  patch  "password/reset/:token", to: "password_resets#update"

  # Search
  get "search", to: "search#index", as: :search

  # Public articles
  resources :articles, only: [ :index, :show ], param: :slug do
    resources :comments, only: [ :create, :destroy ], module: :articles
  end

  # Public categories
  resources :categories, only: [ :index, :show ], param: :slug

  # Tags
  resources :tags, only: [ :show ], param: :slug

  # Admin namespace
  namespace :admin do
    root "dashboard#index"

    resources :articles do
      member do
        patch :publish
        patch :archive
        patch :unpublish
      end
    end

    resources :categories
    resources :tags
    resources :pages

    resources :comments, only: [ :index, :show, :destroy ] do
      member do
        patch :approve
        patch :reject
      end
    end

    resources :users do
      member do
        patch :toggle_active
      end
    end
  end

  # Static pages (catch-all — must be LAST)
  resources :pages, only: [ :show ], param: :slug, path: ""
end
