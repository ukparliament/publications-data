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

    get_publication = Datagraphs::Api::GetPublication.new

    publication = get_publication.and_published_publication_details(publication_work_id: @publication_work_id).first
    @publication = OpenStruct.new(publication)

    optional_extras = get_publication.and_optional_extras(publication_work_id: @publication_work_id).first
    @optional_extras = OpenStruct.new(optional_extras)

    title = @publication.title

    @concepts = @optional_extras.concepts.map { |c| OpenStruct.new(c) }
    @supersedes = @optional_extras.supersedes.map { |c| OpenStruct.new(c) }
    @superseded_by = @optional_extras.superseded_by.map { |c| OpenStruct.new(c) }
    @merged_from = @optional_extras.merged_from.map { |c| OpenStruct.new(c) }
    @split_from = @optional_extras.split_from.map { |c| OpenStruct.new(c) }

    # We do this differently as we need to merge the dates in there
    @disclaimers = @optional_extras.disclaimer_ids ? @optional_extras.disclaimer_labels.zip(@optional_extras.disclaimers_applicable_from) : []

    @withdrawal_periods = @optional_extras.wps.map do |w|
      # Transform keys in place from JS style camel case
      if w["reinstatedAt"].present?
        w["reinstated_at"] = nice_date_time(w["reinstatedAt"])
      end

      w["withdrawn_at"] = nice_date_time(w["withdrawnAt"])

      OpenStruct.new(w)
    end.sort_by { |wp| wp.withdrawn_at }.reverse

    contributions = get_publication.and_contributors(publication_work_id: @publication_work_id).uniq
    @contributions = contributions.map { |contribution| OpenStruct.new(contribution) }

    resources = get_publication.and_resources(publication_work_id: @publication_work_id)
    @resources = resources.map { |resource| OpenStruct.new(resource) if resource["file_title"].present? }

    @crumb << { label: MAIN_PAGE_TITLE, url: publications_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end
end
