class User::GithubSolutionSyncer::GenerateCommitMessage
  include Mandate

  initialize_with :syncer, :iteration

  def call
    template = syncer.commit_message_template

    template.
      gsub("$track_title", track.title).
      gsub("$track_slug", track.slug).
      gsub("$exercise_title", exercise.title).
      gsub("$exercise_slug", exercise.slug).
      gsub("$iteration_idx", iteration.idx.to_s).
      gsub("$sync_object", "Iteration").
      gsub("//", "/")
  end

  delegate :user, :exercise, :track, to: :iteration
end
