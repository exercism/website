class Test::Components::Student::EditorController < Test::BaseController
  def show
    @solution = Solution.find(params[:solution_id])
  end
end
