require "test_helper"

class ProcessPullRequestUpdateJobTest < ActiveJob::TestCase
  test "reputation tokens are awarded for pull request" do
    # TODO: figure out how to match the reviews sawyerresource with the expected hash
    skip

    action = 'closed'
    login = 'user22'
    url = 'https://api.github.com/repos/exercism/fsharp/pulls/1347'
    html_url = 'https://github.com/exercism/fsharp/pull/1347'
    labels = %w[bug duplicate]
    repo = 'exercism/fsharp'
    number = 1347
    reviews = [
      { user: { login: "reviewer71" } },
      { user: { login: "reviewer13" } }
    ]

    RestClient.unstub(:get)
    stub_request(:get, "https://api.github.com/repos/exercism/fsharp/pulls/1347/reviews").
      to_return(status: 200, body: reviews.to_json, headers: { 'Content-Type' => 'application/json' })

    User::ReputationToken::AwardForPullRequest.expects(:call).with(action, login,
      url: url,
      html_url: html_url,
      labels: labels,
      repo: repo,
      number: number,
      reviews: reviews)

    ProcessPullRequestUpdateJob.perform_now(action, login,
      url: url,
      html_url: html_url,
      labels: labels,
      repo: repo,
      number: number)
  end
end
