class API::SolutionSerializer
  include Rails.application.routes.url_helpers

  attr_reader :solution, :requester
  def initialize(solution, requester)
    @solution = solution
    @requester = requester
  end

  def to_hash
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
        iteration: iteration_hash
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
    if solution.user == requester
      Exercism::Routes.personal_solution_url(solution)
    else
      # TODO: Don't let someone download a personal_uuid and
      # end up with the mentor_uuid here.
      #
      # TODO: How is this actually used within the CLI and could
      # we just have it as nil if the user isn't the requestor?
      Exercism::Routes.mentor_solution_url(solution)
    end
  end

  def instructions_url
    Exercism::Routes.personal_solution_url(solution)
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
    fs += iteration.files.pluck(:filename) if iteration
    fs
  end

  def iteration_hash
    return nil unless iteration

    { submitted_at: iteration.created_at }
  end

  def iteration
    @iteration ||= solution.iterations.last
  end

  def routes
    @routes ||= Rails.application.routes.url_helpers
  end

  def track
    @track ||= solution.exercise.track
  end
end
