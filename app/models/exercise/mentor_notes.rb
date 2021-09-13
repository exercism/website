class Exercise
  class MentorNotes
    # Yes, the exercise slug should be duplicated. I think this is a GitHub bug.
    NEW_GITHUB_URL = "https://github.com/exercism/website-copy/new/main/tracks/%<track_slug>s/exercises/%<exercise_slug>s?filename=%<exercise_slug>s/mentoring.md".freeze
    EDIT_GITHUB_URL = "https://github.com/exercism/website-copy/edit/main/tracks/%<track_slug>s/exercises/%<exercise_slug>s/mentoring.md".freeze

    def initialize(exercise, copy_repo: Git::WebsiteCopy.new)
      @exercise = exercise
      @copy_repo = copy_repo
    end

    def to_s
      markdown = copy_repo.mentor_notes_for(track.slug, exercise.slug).strip
      Markdown::Parse.(markdown)
    end

    def edit_url
      url = blank? ? NEW_GITHUB_URL : EDIT_GITHUB_URL

      format(url, track_slug: track.slug, exercise_slug: exercise.slug)
    end

    delegate :blank?, to: :to_s

    private
    attr_reader :exercise, :copy_repo

    def track
      exercise.track
    end
  end
end
