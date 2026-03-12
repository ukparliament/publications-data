namespace :load do
  desc "load datasets"
  task datasets: :environment do
    ap "Datasets count #{Dataset.count}"
    Dataset.delete_all
    Datagraphs::Api::GetDatasets.new.process
    ap "Datasets count afterwards #{Dataset.count}"
  end

  desc "load all concepts"
  task concepts: :environment do
    Concept.delete_all
    ap "Concept count #{Concept.count} for "
    Dataset.all.each do |dataset|
      ap "Looking for #{dataset.name.parameterize} in the API"
      Datagraphs::Api::SearchForConcepts.new.process(dataset.name.parameterize)
    end
    ap "Concept count afterwards #{Concept.count}"
  end

  # desc "load all concepts"
  # task expression_statuses: :environment do
  #   # Concept.delete_all
  #   ap "Concept count #{Concept.count} for "
  #   Datagraphs::Api::SearchForConcepts.new.process("publication-expression-statuses")

  #   ap "Concept count afterwards #{Concept.count}"
  # end



#   Publication expression statuses
# Publications
# Withdrawals

  task routes: :environment do
    Rails.application.reload_routes!
  end

  desc "Debug concepts"
  task debug_concepts: :environment do
    Concept.all.each do |c|
      c.properties.each do |k, v|
        if v.instance_of?(Array)
          ap "count: #{v.size} - #{v}" if v.size > 1
        end
      end
    end
  end

  desc "load concept - PublicationExpression"
  task publications: :environment do
    ap "Publication count #{Publication.count}"
    Datagraphs::Api::SearchForConcepts.new.process("publications")
    ap "Concept count afterwards #{Publication.count}"
  end


  desc "load concept - PublicationExpression"
  task all: :environment do
    ap "Publication count #{Publication.count}"
    Datagraphs::Api::SearchForConcepts.new.process("_all")
    ap "Concept count afterwards #{Publication.count}"
  end

  desc "load concept - specialisms"
  task specialisms: :environment do
    ap "Concept count #{Concept.count}"
    Datagraphs::Api::SearchForConcepts.new.process("specialisms")
    ap "Concept count afterwards #{Concept.count}"
  end

  desc "load concept - sections"
  task sections: :environment do
    ap "Concept count #{Concept.count}"
    Datagraphs::Api::SearchForConcepts.new.process("sections")
    ap "Concept count afterwards #{Concept.count}"
  end

  desc "load concept - thesaurus"
  task thesaurus: :environment do
    ap "Concept count #{Concept.count}"
    Datagraphs::Api::SearchForConcepts.new.process("thesaurus")
    ap "Concept count afterwards #{Concept.count}"
  end


end
