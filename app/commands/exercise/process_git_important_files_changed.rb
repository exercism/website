class Exercise
  class ProcessGitImportantFilesChanged
    include Mandate

    initialize_with :exercise

    def call
      RecalculateImportantFilesHashWithSolutions.(exercise)

      return unless testable_files_have_changed?

      Exercise::QueueSolutionHeadTestRuns.defer(self)
      Exercise::MarkSolutionsAsOutOfDateInIndex.defer(self)
    end

    private
    def testable_files_have_changed?
      # If the maintainer has used the manual flag, then
      # don't run anything here
      return false if git_no_important_files_changed?

      # TODO: Guard against just documentation changes

      true
    end
  end
end
