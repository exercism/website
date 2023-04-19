require_relative '../../test_base'

class Donations::Github::Sponsorship::SyncAllTest < Donations::TestBase
  test "creates subscription for known Github user with unknown sponsorship with repeating payment" do
    create :user, github_username: 'user_1'
    create :user, github_username: 'user_2'

    first_response = {
      data: {
        organization: {
          sponsorshipsAsMaintainer: {
            nodes: [
              {
                sponsorEntity: {
                  login: "user_1"
                },
                id: "S_kwHOAFXRv84AASNH",
                privacyLevel: "PUBLIC",
                isOneTimePayment: false,
                tier: {
                  monthlyPriceInCents: 500
                }
              }
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
          sponsorshipsAsMaintainer: {
            nodes: [
              {
                sponsorEntity: {
                  login: "user_2"
                },
                id: "S_kwHOAFXRv84BBEEF",
                privacyLevel: "PRIVATE",
                isOneTimePayment: false,
                tier: {
                  monthlyPriceInCents: 300
                }
              }
            ],
            pageInfo: {
              hasNextPage: false,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orabc'
            }
          }
        },
        rateLimit: {
          remaining: 4990,
          resetAt: '2021-03-10T15:32:50Z'
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

    ProcessGithubSponsorUpdateJob.expects(:perform_later).with('created', 'user_1', 'S_kwHOAFXRv84BBEEF', 'public', false, 500).once
    ProcessGithubSponsorUpdateJob.expects(:perform_later).with('created', 'user_2', 'S_kwHOAFXRv84BBEEF', 'private', false, 300).once

    Donations::Github::Sponsorship::SyncAll.()
  end
end
