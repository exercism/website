module Git
  class Track
    class MentorNotes
      include Mandate

      initialize_with :track_slug

      def content
        markdown = copy_repo.mentor_notes_for_track(track_slug).strip
        Markdown::Parse.(markdown)
      end

      def edit_url
        url = exists? ? EDIT_GITHUB_URL : NEW_GITHUB_URL
        format(url, track_slug:)
      end

      private
      def exists? = content.present?

      memoize
      def copy_repo = Git::WebsiteCopy.new

      NEW_GITHUB_URL = "https://github.com/exercism/website-copy/new/main/tracks/%<track_slug>s?filename=mentoring.md".freeze
      EDIT_GITHUB_URL = "https://github.com/exercism/website-copy/edit/main/tracks/%<track_slug>s/mentoring.md".freeze
      private_constant :NEW_GITHUB_URL, :EDIT_GITHUB_URL
    end
  end
end
