$SITE_TITLE = ENV.fetch("SITE_TITLE")
$TOGGLE_PORTCULLIS = ENV.fetch( "TOGGLE_PORTCULLIS", 'off' )
$PROJECT_ID = ENV.fetch("PROJECT_ID")

class Constants
  ROUTE_OVERRIDES = [
    { title: "Research services for the %{main_concept}", route: "/houses/:id/research-services", to: 'concepts#show', concept_type: "House", property: "hasResearchService", as: :houses_research_services },
    { route: "/houses/:id/publications", to: 'concepts#show', concept_type: "House", property: "hasResearchProperty", as: :houses_publications },
    { title: "Publications", route: "/publications", to: 'concepts#index', concept_type: "PublicationWork", as: :publications },
    { title: "Publication", route: "/publications/:id", to: 'concepts#show', concept_type: "PublicationWork", as: :publication },
  ]

  CONCEPT_TITLE_MAP = {
    "PublicationWork" => "Publications"
  }
end