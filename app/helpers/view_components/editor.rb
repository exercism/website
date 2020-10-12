module ViewComponents
  class Editor < ViewComponent
    def initialize(solution)
      @solution = solution
    end

    def to_s
      react_component("editor", { solution_id: solution.uuid })
    end

    private
    attr_reader :solution
  end
end
