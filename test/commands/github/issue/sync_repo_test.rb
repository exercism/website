require "test_helper"

class Github::Issue::SyncRepoTest < ActiveSupport::TestCase
  test "imports all issues" do
    first_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          issues: {
            nodes: [
              {
                id: "MDU6SXNzdWU3MjM2MjUwMTI=",
                number: 999,
                title: "grep is failing on Windows",
                state: "OPEN",
                createdAt: "2020-10-17T02:39:37Z",
                url: "https://github.com/exercism/ruby/issues/999",
                author: {
                  login: "SleeplessByte"
                },
                labels: {
                  nodes: [
                    { name: "bug" },
                    { name: "good-first-issue" }
                  ]
                }
              },
              {
                id: "MDU6SXNzdWU2MDU0NDM4NDU=",
                number: 850,
                title: "Help out with V3",
                state: "OPEN",
                createdAt: "2020-04-23T11:06:53Z",
                url: "https://github.com/exercism/ruby/issues/850",
                author: {
                  login: "ErikSchierboom"
                },
                labels: {
                  nodes: [
                    { name: "help-wanted" },
                    { name: "good-first-issue" }
                  ]
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
        repository: {
          nameWithOwner: 'exercism/ruby',
          issues: {
            nodes: [
              {
                id: "MDU6SXNzdWU1NDA5NzMxNTY=",
                number: 798,
                title: "Add new exercise: Yacht",
                state: "CLOSED",
                createdAt: "2019-12-20T12:32:47Z",
                url: "https://github.com/exercism/ruby/issues/798",
                author: {
                  login: "iHiD"
                },
                labels: {
                  nodes: []
                }
              }
            ],
            pageInfo: {
              hasNextPage: false,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
            }
          }
        },
        rateLimit: {
          remaining: 4989,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.exclude?("after:") }.
      to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.include?("after: \\\"Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp\\\"") }.
      to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

    Github::Issue::SyncRepo.('exercism/ruby')

    issues = ::Github::Issue.all
    assert_equal 3, issues.size

    assert_equal 'MDU6SXNzdWU3MjM2MjUwMTI=', issues.first.node_id
    assert_equal 999, issues.first.number
    assert_equal 'grep is failing on Windows', issues.first.title
    assert_equal :open, issues.first.status
    assert_equal 'exercism/ruby', issues.first.repo
    assert_equal %w[bug good-first-issue], issues.first.labels.pluck(:name).sort
    assert_equal Time.parse('2020-10-17T02:39:37Z').utc, issues.first.opened_at
    assert_equal 'SleeplessByte', issues.first.opened_by_username

    assert_equal 'MDU6SXNzdWU2MDU0NDM4NDU=', issues.second.node_id
    assert_equal 850, issues.second.number
    assert_equal 'Help out with V3', issues.second.title
    assert_equal :open, issues.second.status
    assert_equal 'exercism/ruby', issues.second.repo
    assert_equal %w[good-first-issue help-wanted], issues.second.labels.pluck(:name).sort
    assert_equal Time.parse('2020-04-23T11:06:53Z').utc, issues.second.opened_at
    assert_equal 'ErikSchierboom', issues.second.opened_by_username

    assert_equal 'MDU6SXNzdWU1NDA5NzMxNTY=', issues.third.node_id
    assert_equal 798, issues.third.number
    assert_equal 'Add new exercise: Yacht', issues.third.title
    assert_equal :closed, issues.third.status
    assert_equal 'exercism/ruby', issues.third.repo
    assert_empty issues.third.labels.pluck(:name)
    assert_equal Time.parse('2019-12-20T12:32:47Z').utc, issues.third.opened_at
    assert_equal 'iHiD', issues.third.opened_by_username
  end

  test "imports issue without author" do
    response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          issues: {
            nodes: [
              {
                id: "MDU6SXNzdWU3MjM2MjUwMTI=",
                number: 999,
                title: "grep is failing on Windows",
                state: "OPEN",
                createdAt: "2020-10-17T02:39:37Z",
                url: "https://github.com/exercism/ruby/issues/999",
                author: nil,
                labels: {
                  nodes: [
                    { name: "bug" },
                    { name: "good-first-issue" }
                  ]
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
          remaining: 4991,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

    Github::Issue::SyncRepo.('exercism/ruby')

    issue = ::Github::Issue.find_by(node_id: 'MDU6SXNzdWU3MjM2MjUwMTI=')
    assert_equal 'MDU6SXNzdWU3MjM2MjUwMTI=', issue.node_id
    assert_equal 999, issue.number
    assert_equal 'grep is failing on Windows', issue.title
    assert_equal :open, issue.status
    assert_equal 'exercism/ruby', issue.repo
    assert_equal %w[bug good-first-issue], issue.labels.pluck(:name).sort
    assert_equal Time.parse('2020-10-17T02:39:37Z').utc, issue.opened_at
    assert_nil issue.opened_by_username
  end

  test "fetch all issues even if rate limit is reached" do
    first_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          issues: {
            nodes: [
              {
                id: "MDU6SXNzdWU3MjM2MjUwMTI=",
                number: 999,
                title: "grep is failing on Windows",
                state: "OPEN",
                createdAt: "2020-10-17T02:39:37Z",
                url: "https://github.com/exercism/ruby/issues/999",
                author: {
                  login: "SleeplessByte"
                },
                labels: {
                  nodes: [
                    { name: "bug" },
                    { name: "good-first-issue" }
                  ]
                }
              },
              {
                id: "MDU6SXNzdWU2MDU0NDM4NDU=",
                number: 850,
                title: "Help out with V3",
                state: "OPEN",
                createdAt: "2020-04-23T11:06:53Z",
                url: "https://github.com/exercism/ruby/issues/850",
                author: {
                  login: "ErikSchierboom"
                },
                labels: {
                  nodes: [
                    { name: "help-wanted" },
                    { name: "good-first-issue" }
                  ]
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
          remaining: 0,
          resetAt: 5.seconds.from_now.utc.iso8601
        }
      }
    }

    second_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          issues: {
            nodes: [
              {
                id: "MDU6SXNzdWU1NDA5NzMxNTY=",
                number: 798,
                title: "Add new exercise: Yacht",
                state: "CLOSED",
                createdAt: "2019-12-20T12:32:47Z",
                url: "https://github.com/exercism/ruby/issues/798",
                author: {
                  login: "iHiD"
                },
                labels: {
                  nodes: []
                }
              }
            ],
            pageInfo: {
              hasNextPage: false,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
            }
          }
        },
        rateLimit: {
          remaining: 4989,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.exclude?("after:") }.
      to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.include?("after: \\\"Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp\\\"") }.
      to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

    Github::Issue::SyncRepo.('exercism/ruby')

    assert_equal 3, ::Github::Issue.find_each.size
  end

  test "waits for rate limit to reset if rate limit was reached while fetching" do
    first_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          issues: {
            nodes: [
              {
                id: "MDU6SXNzdWU3MjM2MjUwMTI=",
                number: 999,
                title: "grep is failing on Windows",
                state: "OPEN",
                createdAt: "2020-10-17T02:39:37Z",
                url: "https://github.com/exercism/ruby/issues/999",
                author: {
                  login: "SleeplessByte"
                },
                labels: {
                  nodes: [
                    { name: "bug" },
                    { name: "good-first-issue" }
                  ]
                }
              },
              {
                id: "MDU6SXNzdWU2MDU0NDM4NDU=",
                number: 850,
                title: "Help out with V3",
                state: "OPEN",
                createdAt: "2020-04-23T11:06:53Z",
                url: "https://github.com/exercism/ruby/issues/850",
                author: {
                  login: "ErikSchierboom"
                },
                labels: {
                  nodes: [
                    { name: "help-wanted" },
                    { name: "good-first-issue" }
                  ]
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
          remaining: 0,
          resetAt: 5.seconds.from_now.utc.iso8601
        }
      }
    }

    second_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          issues: {
            nodes: [
              {
                id: "MDU6SXNzdWU1NDA5NzMxNTY=",
                number: 798,
                title: "Add new exercise: Yacht",
                state: "CLOSED",
                createdAt: "2019-12-20T12:32:47Z",
                url: "https://github.com/exercism/ruby/issues/798",
                author: {
                  login: "iHiD"
                },
                labels: {
                  nodes: []
                }
              }
            ],
            pageInfo: {
              hasNextPage: false,
              endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
            }
          }
        },
        rateLimit: {
          remaining: 4989,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    RestClient.unstub(:post)
    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.exclude?("after:") }.
      to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:post, "https://api.github.com/graphql").
      with { |request| request.body.include?("after: \\\"Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp\\\"") }.
      to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

    start = Time.now.utc
    Github::Issue::SyncRepo.('exercism/ruby')
    elapsed = Time.now.utc - start

    assert elapsed > 5.seconds
  end
end
