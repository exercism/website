module Git
  class Exercise
    class MentorNotes
      include Mandate

      initialize_with :track_slug, :exercise_slug

      def content
        markdown = copy_repo.mentor_notes_for_exercise(track_slug, exercise_slug).strip
        Markdown::Parse.(markdown)
      end

      def edit_url
        url = exists? ? EDIT_GITHUB_URL : NEW_GITHUB_URL

        format(url, track_slug:, exercise_slug:)
      end

      private
      def exists? = content.present?

      memoize
      def copy_repo
        Git::WebsiteCopy.new
      end

      # Yes, the exercise slug should be duplicated. I think this is a GitHub bug.
      NEW_GITHUB_URL = "https://github.com/exercism/website-copy/new/main/tracks/%<track_slug>s/exercises/%<exercise_slug>s?filename=%<exercise_slug>s/mentoring.md".freeze
      EDIT_GITHUB_URL = "https://github.com/exercism/website-copy/edit/main/tracks/%<track_slug>s/exercises/%<exercise_slug>s/mentoring.md".freeze
      private_constant :NEW_GITHUB_URL, :EDIT_GITHUB_URL
    end
  end
end
