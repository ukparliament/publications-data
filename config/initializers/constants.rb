$SITE_TITLE = ENV.fetch("SITE_TITLE", "Research Publications Explorer")
$TOGGLE_PORTCULLIS = ENV.fetch( "TOGGLE_PORTCULLIS", 'on' )
$DATAGRAPHS_PROJECT_ID = ENV.fetch("DATAGRAPHS_PROJECT_ID", "publications-data")
$DISABLE_AUTHENTICATION = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DISABLE_AUTHENTICATION", false))
$PRODUCT_TITLE  = $SITE_TITLE
