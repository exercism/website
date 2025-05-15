class API::Solutions::SubmissionsController < API::BaseController
  def create
    begin
      solution = Solution.find_by!(uuid: params[:solution_uuid])
    rescue ActiveRecord::RecordNotFound
      return render_solution_not_found
    end

    return render_solution_not_accessible unless solution.user_id == current_user.id

    files = submission_params[:files].map(&:to_h).map(&:symbolize_keys)
    test_results = submission_params[:test_results]

    # TODO: (Optional) Move this check into a guard service along with the CLI, which raises and
    # rescues SubmissionFileTooLargeError exceptions
    return render_error(400, :file_too_large) if files.any? { |file| file[:content].size > 1.megabyte }

    # TODO: (Required) Allow rerunning of tests if previous submission was an error / ops error / timeout
    begin
      submission = Submission::Create.(solution, files, :api, test_results.to_json)
    rescue DuplicateSubmissionError
      return render_error(400, :duplicate_submission)
    end

    render json: {
      submission: SerializeSubmission.(submission)
    }, status: :created
  end

  private
  def submission_params
    params.permit(
      files: %i[filename content type],
      test_results: [
        :version,
        :status,
        :message,
        :messageHtml,
        :output,
        :outputHtml,
        :highlightjsLanguage,
        { links: [:self] },
        { tests: %i[name status testCode message messageHtml expected output outputHtml taskId] },
        { tasks: [] }
      ]
    )
  end
end
