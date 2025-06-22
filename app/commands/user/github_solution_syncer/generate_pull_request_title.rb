class User::GithubSolutionSyncer::GeneratePullRequestTitle
  include Mandate

  initialize_with :syncer, :sync_object, track: nil, exercise: nil, iteration: nil

  def call
    template = syncer.commit_message_template

    template.
      gsub("$track_title", track&.title.to_s).
      gsub("$track_slug", track&.slug.to_s).
      gsub("$exercise_title", exercise&.title.to_s).
      gsub("$exercise_slug", exercise&.slug.to_s).
      gsub("$iteration_idx", iteration&.idx.to_s).
      gsub("$sync_object", sync_object).
      gsub(%r{/[/\s]*/}, "/").
      gsub(%r{/$}, "").
      gsub(%r{^/}, "").
      gsub(/-[-\s]*-/, "-").
      gsub(/-$/, "").
      gsub(/^-/, "")
  end

  delegate :user, :exercise, :track, to: :iteration
end
