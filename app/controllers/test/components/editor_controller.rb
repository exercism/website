class Test::Components::EditorController < Test::BaseController
  def show
    @solution = Solution.find(params[:solution_id])
  end
end
