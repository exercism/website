module ViewComponents
  class Bootcamp::ProjectWidget < ViewComponent
    initialize_with :project, user_project: nil

    def to_s
      render template: "components/bootcamp/project_widget", locals: {
        project:,
        user_project:,
        status:
      }
    end

    private
    def status
      return :available if !user_project && project.unlocked?

      user_project.status
    end
  end
end
