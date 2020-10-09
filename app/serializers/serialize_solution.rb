class SerializeSolution
  include Mandate

  initialize_with :solution, :requester

  def call
    {
      solution: {
        id: solution.uuid,
        url: solution_url,
        user: {
          handle: user_handle,
          is_requester: solution.user_id == requester.id
        },
        exercise: {
          id: solution.exercise.slug,
          instructions_url: instructions_url,
          track: {
            id: track.slug,
            language: track.title
          }
        },
        file_download_base_url: file_download_base_url,
        files: files,
        submission: submission_hash
      }
    }
  end

  private
  def user_handle
    # Handles can change on anonymous tracks
    user_track = UserTrack.find_by!(track: track, user: solution.user)
    if user_track.anonymous_during_mentoring?
      solution.anonymised_user_handle
    else
      solution.user.handle
    end
  end

  def solution_url
    # TODO: Don't let someone download a personal_uuid and
    # end up with the mentor_uuid here. Actively guard this.
    #
    # TODO: How is this actually used within the CLI and could
    # we just have it as nil if the user isn't the requestor?
    return nil unless solution.user == requester

    Exercism::Routes.private_solution_url(solution)
  end

  def instructions_url
    Exercism::Routes.private_solution_url(solution)
  end

  def file_download_base_url
    "#{Exercism.config.api_host}/v1/solutions/#{solution.uuid}/files/"
  end

  def files
    fs = Set.new
    git_exercise = Git::Exercise.for_solution(solution)
    git_exercise.filepaths.each do |filepath|
      fs.add(filepath) unless filepath&.match?(track.repo.ignore_regexp)
    end
    fs += submission.files.pluck(:filename) if submission
    fs
  end

  def submission_hash
    return nil unless submission

    { submitted_at: submission.created_at }
  end

  def submission
    @submission ||= solution.submissions.last
  end

  def track
    @track ||= solution.exercise.track
  end
end
