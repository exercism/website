require_relative '../../test_base'

class Payments::Github::Sponsorship::SyncAllTest < Payments::TestBase
  test "creates missing subscriptions and payments" do
    user_1 = create :user, github_username: 'user_1'
    user_2 = create :user, github_username: 'user_2'

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
                isOneTimePayment: true,
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

    Payments::Github::Sponsorship::SyncAll.()

    assert_enqueued_with(job: MandateJob, args: [
                           Payments::Github::Sponsorship::HandleCreated.name,
                           user_1,
                           "S_kwHOAFXRv84AASNH",
                           false,
                           500
                         ])

    assert_enqueued_with(job: MandateJob, args: [
                           Payments::Github::Sponsorship::HandleCreated.name,
                           user_2,
                           "S_kwHOAFXRv84BBEEF",
                           true,
                           300
                         ])
  end

  test "updates subscriptions" do
    user_1 = create :user, github_username: 'user_1', show_on_supporters_page: true
    user_2 = create :user, github_username: 'user_2', show_on_supporters_page: false

    create :payments_payment, :github, user: user_1, external_id: "S_kwHOAFXRv84AASNH"
    create :payments_subscription, :github, :active, user: user_1, external_id: "S_kwHOAFXRv84AASNH", amount_in_cents: 500
    create :payments_payment, :github, user: user_2, external_id: "S_kwHOAFXRv84BBEEF"
    create :payments_subscription, :github, :active, user: user_2, external_id: "S_kwHOAFXRv84BBEEF", amount_in_cents: 300

    response = {
      data: {
        organization: {
          sponsorshipsAsMaintainer: {
            nodes: [
              {
                sponsorEntity: {
                  login: "user_1"
                },
                id: "S_kwHOAFXRv84AASNH",
                isOneTimePayment: false,
                tier: {
                  monthlyPriceInCents: 1500
                }
              },
              {
                sponsorEntity: {
                  login: "user_2"
                },
                id: "S_kwHOAFXRv84BBEEF",
                isOneTimePayment: false,
                tier: {
                  monthlyPriceInCents: 600
                }
              }
            ],
            pageInfo: {
              hasNextPage: false,
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

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.include?('"endCursor":null') }.
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

    Payments::Github::Sponsorship::SyncAll.()

    assert_enqueued_with(job: MandateJob, args: [
                           Payments::Github::Sponsorship::HandleTierChanged.name,
                           user_1,
                           "S_kwHOAFXRv84AASNH",
                           false,
                           1500
                         ])

    assert_enqueued_with(job: MandateJob, args: [
                           Payments::Github::Sponsorship::HandleTierChanged.name,
                           user_2,
                           "S_kwHOAFXRv84BBEEF",
                           false,
                           600
                         ])
  end

  test "cancel missing subscriptions" do
    user_1 = create :user, github_username: 'user_1', show_on_supporters_page: true
    user_2 = create :user, github_username: 'user_2', show_on_supporters_page: false

    create :payments_subscription, user: user_1, external_id: "S_kwHOAFXRv84AASNH", provider: :github,
      status: :active, amount_in_cents: 500
    create :payments_subscription, user: user_2, external_id: "S_kwHOAFXRv84BBEEF", provider: :github,
      status: :active, amount_in_cents: 300

    response = {
      data: {
        organization: {
          sponsorshipsAsMaintainer: {
            nodes: [
              {
                sponsorEntity: {
                  login: "user_1"
                },
                id: "S_kwHOAFXRv84AASNH",
                isOneTimePayment: false,
                tier: {
                  monthlyPriceInCents: 500
                }
              }
            ],
            pageInfo: {
              hasNextPage: false,
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

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.include?('"endCursor":null') }.
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

    Payments::Github::Sponsorship::SyncAll.()

    assert_enqueued_with(job: MandateJob, args: [
                           Payments::Github::Sponsorship::HandleCancelled.name,
                           user_2,
                           "S_kwHOAFXRv84BBEEF",
                           false
                         ])
  end
end
