class Test::Components::Student::EditorController < Test::BaseController
  def show
    @solution = Solution.first
  end
end
