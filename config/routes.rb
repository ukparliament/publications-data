# frozen_string_literal: true

Rails.application.routes.draw do
  mount LibraryDesign::Engine => "/library_design"

  root "datasets#index"

  get '/' => 'home#index', as: :home

  get 'datasets' => "datasets#index", as: :datasets
  get 'concepts' => "concepts#index", as: :concepts

  get 'meta/cookies' => 'meta#cookies', as: :meta_cookies

  get 'houses/:house/james-service' => 'concepts#index'

  Dataset.all_concept_types.each do |concept_types|
    get "/#{concept_types}",      to: 'concepts#index', defaults: { concept_type: concept_types.underscore.camelize.singularize }
    get "/#{concept_types}/:id",  to: 'concepts#show',  defaults: { concept_type: concept_types.underscore.camelize.singularize }, as: concept_types.singularize.underscore.to_sym
  end

  Constants::ROUTE_OVERRIDES.each do |special|
    get special[:route], to: special[:to], defaults: { concept_type: special[:concept_type], property: special[:property] }, as: special[:as]
  end
end

