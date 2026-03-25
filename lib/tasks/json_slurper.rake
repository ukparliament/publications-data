namespace :json do
  task load: :environment do
    #json = JSON.parse('data/publications-20260306161312410.json')

    entries = File.readlines('data/publications-20260306161312410.json').map { |line| JSON.parse(line, symbolize_names: true) }

    #ap entries.map { |record| [record[:type], record.keys]}.uniq

    STANDARD_KEYS = ["label", "type", "id"]

    count = 0

    entries.each_slice(500) do |batch|
      ActiveRecord::Base.transaction do
        ap "Processing batch #{count}"
        batch.each do |single_record|
          label = single_record[:label]
          datagraphs_type = single_record[:type]
          datagraphs_id = single_record[:id]

          STANDARD_KEYS.each { |key| single_record.delete(key) }

          #ap datagraphs_type

          Concept.where(
            label: label,
            datagraphs_type: datagraphs_type,
            datagraphs_id: datagraphs_id,
            properties: single_record

          ).first_or_create!
        end
        count = count + 1
      end
    end

    # (0...100).each do |index|
    #   ap entries[index]
    # end
  end
end


