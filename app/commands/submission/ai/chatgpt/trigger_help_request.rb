class Submission::AI::ChatGPT::TriggerHelpRequest
  include Mandate

  initialize_with :submission

  def call
    Exercism.config.lines_of_code_counter_url = "foo"
    data = {
      submission_id: submission.id,
      type: :help,

      track_title: track.title,
      instructions: formatted_instructions,
      tests: formatted_tests,
      submission: formatted_submission_files
    }.to_json

    # We want to trigger this then forget about it.
    # We don't care about the result as that gets fired back
    # to the SPI when it's ready.
    Thread.new do
      RestClient.post(
        Exercism.config.lines_of_code_counter_url,
        data,
        { content_type: :json, accept: :json }
      )
    end
  end

  private
  delegate :solution, :track, to: :submission

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
