module ToolingJob
  class Create
    include Mandate

    initialize_with :type, :submission_uuid, :language, :exercise, :attributes

    def call
      Exercism::ToolingJob.create!(type, submission_uuid, language, exercise, attributes)
    end
  end
end
