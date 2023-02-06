class Github::Issue::OpenForDocSyncFailure
  include Mandate

  initialize_with :document, :section, :exception, :git_sha

  def call
    Github::Issue::Open.(repo, title, body)
  end

  private
  def repo
    Document::REPO_NAME
  end

  def title
    "🤖 Document sync error for commit #{git_sha[0..5]}"
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
