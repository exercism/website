class Tooling::Representer::HandleDeploy
  include Mandate

  queue_as :dribble

  initialize_with :track

  def call
    old_representer_version = track.representer_version
    Track::UpdateRepresenterVersion.(track)
    return if old_representer_version == track.representer_version

    Exercise::Representation.where(track:).with_feedback.includes(source_submission: :exercise).find_each do |representation|
      submission = representation.source_submission
      Submission::Representation::Init.(submission, type: :exercise, git_sha: submission.exercise.git_sha, run_in_background: true)
    end
  end
end
