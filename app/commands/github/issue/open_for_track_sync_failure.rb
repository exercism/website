module Github
  class Issue
    class OpenForTrackSyncFailure
      include Mandate

      initialize_with :track, :exception, :git_sha

      def call
        return if deadlock_exception?

        Github::Issue::Open.(repo, title, body)
      end

      private
      def deadlock_exception?
        exception.is_a?(ActiveRecord::Deadlocked)
      end

      def repo
        "exercism/#{track.slug}"
      end

      def title
        "🤖 Sync error for commit #{git_sha[0..5]}"
      end

      def body
        <<~BODY.strip
          We hit an error trying to sync the latest commit (#{git_sha}) to the website.

          The error was:
          ```
          #{exception.message}

          #{exception.backtrace.join("\n")}
          ```

          Please tag @exercism/maintainers-admin if you require more information.
        BODY
      end
    end
  end
end
