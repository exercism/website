require "test_helper"

class Github::Sponsors::SyncRepoTest < ActiveSupport::TestCase
  test "imports all pull requests" do
    first_response = {
      data: {
        organization: {
          sponsors: {
            nodes: [
              { login: 'ErikSchierboom' },
              { login: 'iHiD' }
            ],
            pageInfo: {
              hasNextPage: true,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
            }
          }
        },
        rateLimit: {
          remaining: 4991,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    second_response = {
      data: {
        organization: {
          sponsors: {
            nodes: [
              { login: 'dem4ron' }
            ],
            pageInfo: {
              hasNextPage: false,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
            }
          }
        },
        rateLimit: {
          remaining: 4990,
          resetAt: '2021-03-10T15:32:52Z'
        }
      }
    }

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.include?('"endCursor":null') }.
      to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.exclude?('"endCursor":null') }.
      to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

    ProcessGithubSponsorUpdateJob.expects(:perform_later).with('created', 'ErikSchierboom').once
    ProcessGithubSponsorUpdateJob.expects(:perform_later).with('created', 'iHiD').once
    ProcessGithubSponsorUpdateJob.expects(:perform_later).with('created', 'dem4ron').once

    Github::Sponsors::Sync.()
  end

  test "waits for rate limit to reset if rate limit was reached while fetching" do
    first_response = {
      data: {
        organization: {
          sponsors: {
            nodes: [
              { login: 'ErikSchierboom' },
              { login: 'iHiD' }
            ],
            pageInfo: {
              hasNextPage: true,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
            }
          }
        },
        rateLimit: {
          remaining: 0,
          resetAt: 2.seconds.from_now.utc.iso8601
        }
      }
    }

    second_response = {
      data: {
        organization: {
          sponsors: {
            nodes: [
              { login: 'dem4ron' }
            ],
            pageInfo: {
              hasNextPage: false,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
            }
          }
        },
        rateLimit: {
          remaining: 4990,
          resetAt: '2021-03-10T15:32:52Z'
        }
      }
    }

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.include?('"endCursor":null') }.
      to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.exclude?('"endCursor":null') }.
      to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

    start = Time.now.utc
    Github::Sponsors::Sync.()
    elapsed = Time.now.utc - start

    assert elapsed > 2.seconds
  end
end
