module ReactComponents
  class Bootcamp::FrontendExercisePage < ReactComponent
    def to_s
      super(id, data)
    end

    def id = "bootcamp-frontend-exercise-page"

    def data
      {}
    end
  end
end
