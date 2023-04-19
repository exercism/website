class Submission::AI::ChatGPT::GetHelp
  include Mandate

  initialize_with :submission

  def call
    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages:,
        temperature: 0.3
      }
    )
    response.dig("choices", 0, "message", "content")
  end

  private
  delegate :solution, to: :submission

  memoize
  def client
    OpenAI::Client.new(
      access_token: "",
      request_timeout: 240
    )
  end

  def messages
    [
      { role: "system", content: system_message },
      { role: "user", content: user_message }
    ]
  end

  def system_message
    SYSTEM_MESSAGE % { language: solution.track.title }
  end

  def user_message
    USER_MESSAGE % {
      language: solution.track.title,
      introduction: solution.introduction.blank? ? "" : Markdown::Render.(solution.introduction, :text),
      instructions: Markdown::Render.(solution.instructions, :text),
      test_suite: formatted_test_suite,
      submission: formatted_submission_files
    }
  end

  def formatted_test_suite
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

  # rubocop:disable Naming/HeredocDelimiterNaming
  SYSTEM_MESSAGE = <<~EOM.chomp
    You are a mentor helping someone get unstuck on a programming problem. The programming language is %<language>s.

    The user will give you three things:
    - The instructions they are following, in Markdown.
    - A test suite they are trying to code against. In the test suite, some tests are marked as skipped. You should ignore this and pretend they are not skipped.
    - Their solution so far.

    You will list 1 - 3 bullet points with hints as to why the solution doesn't work. You can tell them what they're doing wrong and give them a HINT as to how to improve it, but you should NOT give them the correct code.

    You should ONLY give 1-3 bullet points. Do not write any text before the bullet points. Do not write any text after the bullet points.
  EOM

  USER_MESSAGE = <<~EOM.chomp
    The instructions are:

    %<instructions>s
    %<introduction>s

    ---

    The test suite is:
    %<test_suite>s

    ---

    The user's solution is:
    %<submission>s
  EOM
  # rubocop:enable Naming/HeredocDelimiterNaming
end
