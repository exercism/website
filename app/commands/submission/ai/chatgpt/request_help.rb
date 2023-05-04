class Submission::AI::ChatGPT::RequestHelp
  include Mandate

  initialize_with :submission

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

    # We want to trigger this then forget about it.
    # We don't care about the result as that gets fired back
    # to the SPI when it's ready.
    Thread.new do
      RestClient.post(
        Exercism.config.chatgpt_proxy_url,
        data,
        { content_type: :json, accept: :json }
      )
    end
  end

  private
  delegate :solution, :track, :user, to: :submission

  def chatgpt_version
    usage = user.chatgpt_usage

    return '4.0' if !usage['4.0'] || usage['4.0'] < 3
    return '3.5' if !usage['3.5'] || usage['3.5'] < 30

    raise ChatGPTTooManyRequestsError
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
