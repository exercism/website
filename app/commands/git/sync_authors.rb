module Git
  class SyncAuthors < Sync
    include Mandate

    def initialize(exercise)
      super(exercise.track, exercise.synced_to_git_sha)
      @exercise = exercise
    end

    def call
      authors = ::User.where(handle: author_usernames_config)
      authors.find_each { |author| ::Exercise::Authorship::Create.(exercise, author) }

      # This is required to remove authors that were already added
      exercise.update!(authors: authors)

      # TODO: consider what to do with missing authors
      missing_authors = author_usernames_config - authors.pluck(:handle)
      Rails.logger.error "Missing authors: #{missing_authors.join(', ')}" if missing_authors.present?
    end

    private
    attr_reader :exercise

    memoize
    def author_usernames_config
      head_git_exercise.authors.to_a.map { |a| a[:exercism_username] }
    end

    memoize
    def head_git_exercise
      Git::Exercise.new(exercise.slug, exercise.git_type, git_repo.head_sha, repo: git_repo)
    end
  end
end
