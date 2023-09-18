class Submission::AI::ChatGPT::RequestHelp
  include Mandate

  initialize_with :submission, :desired_chatgpt_version, use_thread: true

  def call
    data = {
      submission_uuid: submission.uuid,
      type: :help,

      track_title: track.title,
      instructions: formatted_instructions,
      tests: formatted_tests,
      submission: formatted_submission_files
    }

    # Keep this as small a lock as possible
    user.with_lock do
      data[:chatgpt_version] = chatgpt_version

      User::IncrementUsage.(user, :chatgpt, chatgpt_version)
    end

    # Generally, we want to trigger this then forget about it.
    # We don't care about the result as that gets fired back
    # to the SPI when it's ready. Either way, return the thread
    # or the results at the end of this.
    #
    # Note, it's important that we calculate data OUTSIDE of the
    # thread, which is why we pass it in here rather than materialising
    # it as a method as we normally would.
    use_thread ? Thread.new { ping_chatgpt!(data) } : ping_chatgpt!(data)
  end

  private
  delegate :solution, :track, :user, to: :submission

  def ping_chatgpt!(data)
    RestClient.post(
      Exercism.config.chatgpt_proxy_url,
      data.to_json,
      { content_type: :json, accept: :json }
    )
  end

  memoize
  def chatgpt_version
    usage = user.chatgpt_usage
    allowed_versions = []

    allowed_versions << '4.0' if !usage['4.0'] || usage['4.0'] < 3
    allowed_versions << '3.5' if !usage['3.5'] || usage['3.5'] < 30

    raise ChatGPTTooManyRequestsError if allowed_versions.empty?

    if allowed_versions.include?(desired_chatgpt_version)
      desired_chatgpt_version
    else
      allowed_versions.first
    end
  end

  def formatted_instructions
    introduction = solution.introduction.blank? ? "" : Markdown::Render.(solution.introduction, :text)
    instructions = Markdown::Render.(solution.instructions, :text)

    [introduction, instructions].compact.join("\n\n")
  end

  def formatted_tests
    solution.test_files.each.map do |filename, content|
      <<~TESTS.chomp
        File: #{filename}

        ```
        #{content}
        ```
      TESTS
    end.join("\n\n")
  end

  def formatted_submission_files
    submission.files.map do |file|
      <<~SUBMISSION.chomp
        File: #{file.filename}

        ```
        #{file.content}
        ```
      SUBMISSION
    end.join("\n\n")
  end
end
