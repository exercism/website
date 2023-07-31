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
      submission: "File: foobar.rb\n\n```\nclass Foobar\nend\n```",
      chatgpt_version: '4.0'
    }

    RestClient.expects(:post).with(
      Exercism.config.chatgpt_proxy_url,
      data.to_json,
      { content_type: :json, accept: :json }
    )

    Submission::AI::ChatGPT::RequestHelp.(submission, '4.0', use_thread: false)
  end

  test "Allows 3 4.0 requests then goes to 3.5" do
    submission = create(:submission)
    create(:submission_file, submission:)

    allowances = (['4.0'] * 3) + (['3.5'] * 30)
    allowances.each do |version|
      RestClient.expects(:post).with do |_, data, _|
        assert_equal version, JSON.parse(data)['chatgpt_version']
      end

      Submission::AI::ChatGPT::RequestHelp.(submission, '4.0', use_thread: false)
    ensure
      RestClient.unstub(:post)
    end

    assert_raises ChatGPTTooManyRequestsError do
      Submission::AI::ChatGPT::RequestHelp.(submission, '4.0', use_thread: false)
    end
  end

  test "Honours 4.0 request if possible" do
    submission = create(:submission)
    create(:submission_file, submission:)

    RestClient.expects(:post).with do |_, data, _|
      assert_equal '4.0', JSON.parse(data)['chatgpt_version']
    end

    Submission::AI::ChatGPT::RequestHelp.(submission, '4.0', use_thread: false)
  end

  test "Honours 3.5 request if possible" do
    submission = create(:submission)
    create(:submission_file, submission:)

    RestClient.expects(:post).with do |_, data, _|
      assert_equal '3.5', JSON.parse(data)['chatgpt_version']
    end

    Submission::AI::ChatGPT::RequestHelp.(submission, '3.5', use_thread: false)
  end

  test "Goes to 3.5 if 4.0 fully used" do
    submission = create(:submission)
    create(:submission_file, submission:)
    submission.user.update!(usages: { chatgpt: { '4.0' => 100 } })

    RestClient.expects(:post).with do |_, data, _|
      assert_equal '3.5', JSON.parse(data)['chatgpt_version']
    end

    Submission::AI::ChatGPT::RequestHelp.(submission, '4.0', use_thread: false)
  end

  test "Goes to 4.0 if 3.5 fully used" do
    submission = create(:submission)
    create(:submission_file, submission:)
    submission.user.update!(usages: { chatgpt: { '3.5' => 100 } })

    RestClient.expects(:post).with do |_, data, _|
      assert_equal '4.0', JSON.parse(data)['chatgpt_version']
    end

    Submission::AI::ChatGPT::RequestHelp.(submission, '3.5', use_thread: false)
  end
end
