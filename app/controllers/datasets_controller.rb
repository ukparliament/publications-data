class DatasetsController < AuthenticatedController
  def index
    @datasets = Dataset.all
  end
end