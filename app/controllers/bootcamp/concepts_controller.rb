class Bootcamp::ConceptsController < Bootcamp::BaseController
  def index
    @concepts = Bootcamp::Concept.apex.unlocked

    return if current_user.bootcamp_data.enrolled_in_both_parts?

    if current_user.bootcamp_data.enrolled_on_part_1?
      @concepts = @concepts.part_1
    elsif current_user.bootcamp_data.enrolled_on_part_2?
      @concepts = @concepts.part_2
    end
  end

  def show
    @concept = Bootcamp::Concept.find_by!(slug: params[:slug])
  end
end
