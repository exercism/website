class Track
  class Create
    include Mandate

    initialize_with :slug, :title, :blurb, :repo_url, :synced_to_git_sha, :tags

    def call
      ::Track.create_or_find_by!(slug: slug) do |t|
        t.title = title
        t.blurb = blurb
        t.repo_url = repo_url
        t.synced_to_git_sha = synced_to_git_sha
        t.tags = tags
      end
    end
  end
end
