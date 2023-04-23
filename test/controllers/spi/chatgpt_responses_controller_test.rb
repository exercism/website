require "test_helper"

class SPI::ChatGPTResponsesControllerTest < ActionDispatch::IntegrationTest
  test "proxies to process help request correctly" do
    submission = create :submission
    chatgpt_response = "Something #{SecureRandom.uuid}"

    Submission::AI::ChatGPT::ProcessHelpRequest.expects(:call).with(
      submission, chatgpt_response
    )

    post spi_chatgpt_responses_url(
      submission_uuid: submission.uuid,
      type: 'help',
      chatgpt_response:
    )
  end
end
