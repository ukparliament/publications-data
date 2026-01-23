namespace :load do
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

  desc "load all concepts"
  task concepts: :environment do
    ap "Concept count #{Concept.count} for "
    Dataset.all.each do |dataset|
      Datagraphs::Api::SearchForConcepts.new.process(dataset.name.downcase)
    end
    ap "Concept count afterwards #{Concept.count}"
  end
end
