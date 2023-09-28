module Git
  class WebsiteCopy
    extend Mandate::Memoize

    DEFAULT_REPO_URL = "https://github.com/exercism/website-copy".freeze

    def self.update!
      new.update!
    end

    def initialize(repo_url: DEFAULT_REPO_URL)
      @repo = Repository.new(repo_url:)
    end

    def analysis_comment_for(code)
      filepath = "analyzer-comments/#{code.tr('.', '/')}.md"
      repo.read_text_blob(head_commit, filepath)
    end

    def mentor_notes_for_exercise(track_slug, exercise_slug)
      filepath = "tracks/#{track_slug}/exercises/#{exercise_slug}/mentoring.md"
      repo.read_text_blob(head_commit, filepath)
    end

    def mentor_notes_for_track(track_slug)
      filepath = "tracks/#{track_slug}/mentoring.md"
      repo.read_text_blob(head_commit, filepath)
    end

    memoize
    def automators = repo.read_json_blob(head_commit, "automators.json")

    memoize
    def walkthrough = repo.read_text_blob(head_commit, "walkthrough/index.html")

    def update!
      repo.fetch!
      update_automator_roles!
    end

    def update_automator_roles!
      automators.each do |automator|
        user = User.for!(automator[:username])
        automator[:tracks].each do |track_slug|
          track = ::Track.for!(track_slug)
          User::UpdateAutomatorRole.defer(user, track)
        end
      end
    end

    private
    attr_reader :repo

    delegate :head_commit, to: :repo
  end
end
