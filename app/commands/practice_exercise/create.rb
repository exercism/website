class PracticeExercise
  class Create
    include Mandate

    initialize_with :uuid, :slug, :title, :prerequisites, :deprecated, :git_sha, :synced_to_git_sha, :track

    def call
      ::PracticeExercise.create_or_find_by!(uuid: uuid, track: track) do |e|
        e.slug = slug
        e.title = title
        e.prerequisites = prerequisites
        e.deprecated = deprecated
        e.git_sha = git_sha
        e.synced_to_git_sha = synced_to_git_sha
      end
    end
  end
end
