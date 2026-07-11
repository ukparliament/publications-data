require 'ostruct'

class PublicationsController < AuthenticatedController
  include Pagy::Method
  include ApplicationHelper # For nice date time

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

    ap '*' * 80
    optional_extras = Datagraphs::Api::GetPublication.new.and_optional_extras(publication_work_id: @publication_work_id).first

    ap optional_extras

    ap '*' * 80

    @optional_extras = OpenStruct.new(optional_extras)

    title = @publication.title

    @concepts = @optional_extras.concepts ? @optional_extras.concepts.zip(@optional_extras.concept_ids) : []

    @disclaimers = @optional_extras.disclaimer_ids ? @optional_extras.disclaimer_labels.zip(@optional_extras.disclaimers_applicable_from) : []
    @supersedes = @optional_extras.superseded_ids ? @optional_extras.superseded_ids.zip(@optional_extras.superseded_titles) : []
    @superseded_by = @optional_extras.superseded_by_ids ? @optional_extras.superseded_by_ids.zip(@optional_extras.superseded_by_titles) : []
    @merged_from = @optional_extras.merged_from_ids ? @optional_extras.merged_from_ids.zip(@optional_extras.merged_from_titles) : []
    @split_from = @optional_extras.split_from_ids ? @optional_extras.split_from_ids.zip(@optional_extras.split_from_titles) : []

    @withdrawal_periods = @optional_extras.wps.map do |w|
      # Transform keys in place from JS style camel case
      if w["reinstatedAt"].present?
        w["reinstated_at"] = nice_date_time(w["reinstatedAt"])
      end

      w["withdrawn_at"] = nice_date_time(w["withdrawnAt"])

      OpenStruct.new(w)
    end.sort_by { |wp| wp.withdrawn_at }.reverse

    contributions = Datagraphs::Api::GetPublication.new.get_contributors(publication_work_id: @publication_work_id).uniq
    @contributions = contributions.map { |contribution| OpenStruct.new(contribution) }

    resources = Datagraphs::Api::GetPublication.new.get_resources(publication_work_id: @publication_work_id)
    @resources = resources.map { |resource| OpenStruct.new(resource) if resource["file_title"].present? }

    @crumb << { label: MAIN_PAGE_TITLE, url: publications_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end
end
