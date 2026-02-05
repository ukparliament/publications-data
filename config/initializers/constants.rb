$SITE_TITLE = ENV.fetch("SITE_TITLE")
$TOGGLE_PORTCULLIS = ENV.fetch( "TOGGLE_PORTCULLIS", 'off' )
$PROJECT_ID = ENV.fetch("PROJECT_ID")

class Constants
  ROUTE_OVERRIDES = [
    { route: "/houses/:house/research-services", to: 'concepts#index', concept_type: "House", property: "hasResearchProperty", as: :houses_research_services },
    { route: "/houses/:house/publications", to: 'concepts#index', concept_type: "House", property: "hasResearchProperty", as: :houses_publications },
    { route: "/publications", to: 'concepts#index', concept_type: "PublicationWork", as: :publications },
    { route: "/publications/:id", to: 'concepts#show', concept_type: "PublicationWork", as: :publication },
  ]


  CONCEPT_TITLE_MAP = {
    "PublicationWork" => "Publications"
  }
end