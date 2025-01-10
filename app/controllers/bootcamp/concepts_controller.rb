class Bootcamp::ConceptsController < Bootcamp::BaseController
  def index
    @concepts = Bootcamp::Concept.apex
  end

  def show
    @concept = Bootcamp::Concept.find_by!(slug: params[:slug])
  end
end
