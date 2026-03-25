# frozen_string_literal: true

Rails.application.routes.draw do
  mount LibraryDesign::Engine => "/library_design"

  root "research_services#index"

  get '/' => 'home#index', as: :home

  get 'datasets' => "datasets#index", as: :datasets
  get 'concepts' => "concepts#index", as: :concepts

  get 'meta/cookies' => 'meta#cookies', as: :meta_cookies

  # Dataset.all_concept_type_routes.each do |concept_type_route|
  #   get concept_type_route.nice_url_index_path, to: ConceptTypeRoute::CONCEPTS_INDEX, defaults: { concept_type: concept_type_route.concept_type_for_defaults }
  #   get concept_type_route.nice_url_show_path,  to: ConceptTypeRoute::CONCEPTS_SHOW,  defaults: { concept_type: concept_type_route.concept_type_for_defaults }, as: concept_type_route.show_route_name
  # end

  # Constants::ROUTE_OVERRIDES.each do |special|
  #   get special[:route], to: special[:to], defaults: { concept_type: special[:concept_type], property: special[:property], title: special[:title] }, as: special[:as]
  # end

  resources :houses, only: [:index, :show] do
    member do
      get 'research-services'
      get 'publications'
      get 'publications/unpublished', to: 'houses#unpublished'
    end
  end

  resources :sections, only: [:index, :show]

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
end

