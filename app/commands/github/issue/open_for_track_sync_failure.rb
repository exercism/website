class Github::Issue::OpenForTrackSyncFailure
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
    if git_sha.present?
      "🤖 Sync error for commit #{git_sha[0..5]}"
    else
      "🤖 Sync error: Could not find main branch"
    end
  end

  def body
    <<~BODY.strip
      We hit an error trying to sync the latest commit (#{git_sha || 'unknown'}) to the website.

      The error was:
      ```
      #{exception.message}

      #{exception.backtrace.join("\n")}
      ```

      Please tag @exercism/maintainers-admin if you require more information.
    BODY
  end
end
