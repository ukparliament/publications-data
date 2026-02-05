# frozen_string_literal: true

Rails.application.routes.draw do
  mount LibraryDesign::Engine => "/library_design"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root "datasets#index"
  get '/' => 'home#index', as: :home

  get 'datasets' => "datasets#index", as: :datasets
  get 'concepts' => "concepts#index", as: :concepts

  get 'meta/cookies' => 'meta#cookies', as: :meta_cookies

  Dataset.all_concept_types.each do |ct|
    concept_types = ct.pluralize.underscore.downcase.dasherize

    get "/#{concept_types}", to: 'concepts#index', defaults: { concept_type: concept_types.underscore.camelize.singularize }
    get "/#{concept_types}/:id", to: 'concepts#show', defaults: { concept_type: concept_types.underscore.camelize.singularize }, as: concept_types.singularize.underscore.to_sym
  end

  # Defines the root path route ("/")
  # root "posts#index"
end

