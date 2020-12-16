module ReactComponents
  module Student
    class Editor < ReactComponent
      initialize_with :solution

      def to_s
        super(
          "student-editor",
          {
            endpoint: Exercism::Routes.api_solution_submissions_path(
              solution.uuid
            ),
            submission: SerializeSubmission.(solution.submissions.last),
            files: solution.editor_solution_files.map do |filename, content|
              {
                filename: filename,
                content: content
              }
            end,
            language: solution.editor_language
          }
        )
      end
    end
  end
end
