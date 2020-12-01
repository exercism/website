class Track::Concept
  class Create
    include Mandate

    initialize_with :uuid, :slug, :name, :blurb, :synced_to_git_sha, :track

    def call
      ::Track::Concept.create_or_find_by!(uuid: uuid) do |c|
        c.slug = slug
        c.name = name
        c.blurb = blurb
        c.synced_to_git_sha = synced_to_git_sha
        c.track = track
      end
    end
  end
end
