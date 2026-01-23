namespace :load do
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


  desc "load datasets"
  task datasets: :environment do
    ap "Datasets count #{Dataset.count}"
    Datagraphs::Api::GetDatasets.new.process
    ap "Datasets count afterwards #{Dataset.count}"
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

  desc "load all concepts"
  task concepts: :environment do
    ap "Concept count #{Concept.count} for "
    Dataset.all.each do |dataset|
      Datagraphs::Api::SearchForConcepts.new.process(dataset.name.downcase)
    end
    ap "Concept count afterwards #{Concept.count}"
  end

  task routes: :environment do
    Rails.application.reload_routes!
  end
end
