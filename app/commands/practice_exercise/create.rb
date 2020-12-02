class PracticeExercise
  class Create
    include Mandate

    # :slug, :title, :prerequisites, :deprecated, :git_sha, :synced_to_git_sha,

    initialize_with :uuid, :track, :attributes

    def call
      PracticeExercise.create_or_find_by!(uuid: uuid, track: track) do |pe|
        pe.attributes = attributes
      end
    end
  end
end
