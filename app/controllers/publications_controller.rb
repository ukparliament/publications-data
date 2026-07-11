require 'ostruct'

class PublicationsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Published publications'

  def index
    @total_count = Datagraphs::Api::GetPublications.new.get_total

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    publications = Datagraphs::Api::GetPublications.new.process(
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    publications.each do |pub|
      pub["contributors"] = pub["contributor_ids"].zip(pub["contributor_names"])
    end

    @publications = publications.map { |pub| OpenStruct.new(pub) }

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @publication_work_id = params[:id]

    publication = Datagraphs::Api::GetPublication.new.get_published_publication_details(publication_work_id: @publication_work_id).first
    @publication = OpenStruct.new(publication)

    @concepts = @publication.concepts ? @publication.concepts.zip(@publication.concept_ids) : []

    title = @publication.title

    @disclaimers = @publication.disclaimer_ids ? @publication.disclaimer_labels.zip(@publication.disclaimers_applicable_from) : []
    @supersedes = @publication.superseded_ids ? @publication.superseded_ids.zip(@publication.superseded_titles) : []
    @superseded_by = @publication.superseded_by_ids ? @publication.superseded_by_ids.zip(@publication.superseded_by_titles) : []
    @merged_from = @publication.merged_from_ids ? @publication.merged_from_ids.zip(@publication.merged_from_titles) : []
    @split_from = @publication.split_from_ids ? @publication.split_from_ids.zip(@publication.split_from_titles) : []

    contributions = Datagraphs::Api::GetPublication.new.get_contributors(publication_work_id: @publication_work_id).uniq
    @contributions = contributions.map { |contribution| OpenStruct.new(contribution) }

    resources = Datagraphs::Api::GetPublication.new.get_resources(publication_work_id: @publication_work_id)
    @resources = resources.map { |resource| OpenStruct.new(resource) if resource["file_title"].present? }

    @crumb << { label: MAIN_PAGE_TITLE, url: publications_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end
end
