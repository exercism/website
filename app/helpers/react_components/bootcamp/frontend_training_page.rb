module ReactComponents
  class Bootcamp::FrontendTrainingPage < ReactComponent
    def to_s
      super(id, data)
    end

    def id = "bootcamp-frontend-training-page"

    def data
      {}
    end
  end
end
