require "test_helper"

class SPI::ChatGPTResponsesControllerTest < ActionDispatch::IntegrationTest
  test "proxies to process help request correctly" do
    submission = create :submission
    chatgpt_response = "Something #{SecureRandom.uuid}"
    chatgpt_version = '4.0'

    Submission::AI::ChatGPT::ProcessHelpRequest.expects(:call).with(
      submission, chatgpt_version, chatgpt_response
    )

    post spi_chatgpt_responses_url(
      submission_uuid: submission.uuid,
      type: 'help',
      chatgpt_version:,
      chatgpt_response:
    )
  end
end
