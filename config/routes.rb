# frozen_string_literal: true

Rails.application.routes.draw do
  passwordless_for :users

  mount LibraryDesign::Engine => "/library_design"

  root "home#index"

  get '/' => 'home#index', as: :home

  get 'meta/cookies' => 'meta#cookies', as: :meta_cookies

  resources :houses, only: [:index, :show] do
    member do
      get 'research-services'
      get 'publications'
      get 'publications/unpublished', to: 'houses#unpublished'
    end
  end

  resources :sections, only: [:index, :show]
  resources :collections, only: [:index, :show]
  resources :concepts, only: [:index, :show]

  resources :research_services, path: 'research-services', only: [:index, :show] do
    member do
      get 'publications'
      get 'publications/unpublished'
    end
  end

  resources :publications, only: [:index, :show] do
    collection do
      get 'unpublished'
    end
    member do
      get 'expressions'
    end
  end

  resources :people, only: [:index, :show]
  resources :users
end
