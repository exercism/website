require 'test_helper'

class Submission::AI::ChatGPT::RequestHelpTest < ActiveSupport::TestCase
  test "Proxies out to chatgpt correctly" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:submission_file, submission:)

    data = {
      submission_uuid: submission.uuid,
      type: :help,
      track_title: "Ruby",
      instructions: "Introduction for bob\n\nExtra introduction for bob\n\nInstructions for bob\n\nExtra instructions for bob",
      tests: "File: bob_test.rb\n\n```\ntest content\n\n```",
      submission: "File: foobar.rb\n\n```\nclass Foobar\nend\n```"
    }

    RestClient.expects(:post).with(
      Exercism.config.chatgpt_proxy_url,
      data,
      { content_type: :json, accept: :json }
    )

    Submission::AI::ChatGPT::RequestHelp.(submission)

    sleep(0.1) # Wait for the thread new
  end

  test "Allows 3 4.0 requests then goes to 3.5" do
    submission = create(:submission)
    create(:submission_file, submission:)

    allowances = (['4.0'] * 3) + (['3.5'] * 30)
    allowances.each do |version|
      RestClient.expects(:post).with do |_, data, _|
        assert_equal version, data[:chatgpt_version]
      end

      Submission::AI::ChatGPT::RequestHelp.(submission)

      sleep(0.01) # Wait for the thread new
    ensure
      RestClient.unstub(:post)
    end

    assert_raises ChatGPTTooManyRequestsError do
      Submission::AI::ChatGPT::RequestHelp.(submission)
    end
  end
end
