module MenuHelper
  def menu_items
    Dataset.all_concept_types.map do |concept_type|
      link_to concept_type_conversion(concept_type).capitalize, "/#{concept_type_conversion(concept_type).parameterize.tr('_', '-').pluralize}"
    end
  end

  def menu_item_links
    menu_items.join("&middot; ").html_safe
  end
end
