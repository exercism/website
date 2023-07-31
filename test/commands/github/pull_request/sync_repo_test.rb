require "test_helper"

class Github::PullRequest::SyncRepoTest < ActiveSupport::TestCase
  test "imports all pull requests" do
    first_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/19',
                id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4',
                createdAt: '2021-02-05T15:29:25Z',
                closedAt: nil,
                labels: {
                  nodes: []
                },
                number: 19,
                title: "The cat sat on the mat",
                state: 'OPEN',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: false,
                mergedAt: nil,
                mergedBy: nil,
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx',
                      submittedAt: '2020-03-28T22:44:33Z',
                      author: {
                        login: 'iHiD'
                      }
                    }
                  ]
                }
              },
              {
                url: 'https://github.com/exercism/ruby/pull/8',
                id: 'MDExOlB1bGxSZXF1ZXN0NTYzOTgwNTkw',
                createdAt: '2021-01-29T13:20:35Z',
                closedAt: '2020-04-05T09:10:12Z',
                labels: {
                  nodes: []
                },
                number: 8,
                title: "The cat sat on the mat",
                state: 'CLOSED',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: false,
                mergedAt: nil,
                mergedBy: nil,
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg0MzAyODk0',
                      submittedAt: '2020-02-01T21:55:46Z',
                      author: {
                        login: 'ErikSchierboom'
                      }
                    }
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
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/2',
                id: 'MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz',
                createdAt: '2020-03-27T06:39:20Z',
                closedAt: '2020-03-29T18:24:47Z',
                labels: {
                  nodes: []
                },
                number: 2,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'porkostomus'
                },
                merged: true,
                mergedAt: '2020-03-29T18:24:47Z',
                mergedBy: {
                  login: 'ErikSchierboom'
                },
                reviews: {
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

    Github::PullRequest::SyncRepo.('exercism/ruby')

    prs = ::Github::PullRequest.all
    assert_equal 3, prs.size

    assert_equal 'exercism/ruby', prs.first.repo
    assert_equal "MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4", prs.first.node_id
    assert_equal 19, prs.first.number
    assert_equal :open, prs.first.state
    assert_equal "The cat sat on the mat", prs.first.title
    assert_equal "exercism/ruby", prs.first.repo
    assert_equal "ErikSchierboom", prs.first.author_username
    assert_nil prs.first.merged_by_username
    expected_first_data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/19",
      html_url: "https://github.com/exercism/ruby/pull/19",
      repo: 'exercism/ruby',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4',
      number: 19,
      title: "The cat sat on the mat",
      created_at: Time.parse('2021-02-05T15:29:25Z').utc,
      closed_at: nil,
      state: "open",
      action: "opened",
      author_username: "ErikSchierboom",
      labels: [],
      merged: false,
      merged_at: nil,
      merged_by_username: nil,
      reviews: [
        {
          node_id: "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx",
          submitted_at: Time.parse('2020-03-28T22:44:33Z').utc,
          reviewer_username: "iHiD"
        }
      ]
    }
    assert_equal expected_first_data, prs.first.data
    assert_equal 1, prs.first.reviews.size
    assert_equal "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx", prs.first.reviews.first.node_id
    assert_equal "iHiD", prs.first.reviews.first.reviewer_username

    assert_equal 'exercism/ruby', prs.second.repo
    assert_equal "MDExOlB1bGxSZXF1ZXN0NTYzOTgwNTkw", prs.second.node_id
    assert_equal 8, prs.second.number
    assert_equal :closed, prs.second.state
    assert_equal "The cat sat on the mat", prs.second.title
    assert_equal "exercism/ruby", prs.second.repo
    assert_equal "ErikSchierboom", prs.second.author_username
    assert_nil prs.second.merged_by_username
    expected_second_data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/8",
      html_url: "https://github.com/exercism/ruby/pull/8",
      repo: 'exercism/ruby',
      node_id: 'MDExOlB1bGxSZXF1ZXN0NTYzOTgwNTkw',
      number: 8,
      title: "The cat sat on the mat",
      created_at: Time.parse('2021-01-29T13:20:35Z').utc,
      closed_at: Time.parse('2020-04-05T09:10:12Z').utc,
      state: "closed",
      action: "closed",
      author_username: "ErikSchierboom",
      labels: [],
      merged: false,
      merged_at: nil,
      merged_by_username: nil,
      reviews: [
        {
          node_id: "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg0MzAyODk0",
          submitted_at: Time.parse('2020-02-01T21:55:46Z').utc,
          reviewer_username: "ErikSchierboom"
        }
      ]
    }

    assert_equal expected_second_data, prs.second.data
    assert_equal 1, prs.second.reviews.size
    assert_equal "MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg0MzAyODk0", prs.second.reviews.first.node_id
    assert_equal "ErikSchierboom", prs.second.reviews.first.reviewer_username

    assert_equal 'exercism/ruby', prs.third.repo
    assert_equal "MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz", prs.third.node_id
    assert_equal 2, prs.third.number
    assert_equal :merged, prs.third.state
    assert_equal "The cat sat on the mat", prs.third.title
    assert_equal "exercism/ruby", prs.third.repo
    assert_equal "porkostomus", prs.third.author_username
    assert_equal "ErikSchierboom", prs.third.merged_by_username
    expected_third_data = {
      url: "https://api.github.com/repos/exercism/ruby/pulls/2",
      html_url: "https://github.com/exercism/ruby/pull/2",
      repo: 'exercism/ruby',
      node_id: 'MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz',
      number: 2,
      title: "The cat sat on the mat",
      created_at: Time.parse('2020-03-27T06:39:20Z').utc,
      closed_at: Time.parse('2020-03-29T18:24:47Z').utc,
      state: "merged",
      action: "closed",
      author_username: "porkostomus",
      labels: [],
      merged: true,
      merged_at: Time.parse('2020-03-29T18:24:47Z').utc,
      merged_by_username: "ErikSchierboom",
      reviews: []
    }
    assert_equal expected_third_data, prs.third.data
    assert_empty prs.third.reviews
  end

  test "imports pull request without author" do
    response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/19',
                id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4',
                createdAt: '2021-02-05T15:29:25Z',
                labels: {
                  nodes: []
                },
                number: 19,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: nil,
                merged: true,
                mergedAt: '2020-02-15T02:03:01Z',
                mergedBy: {
                  login: 'iHiD'
                },
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx',
                      submitted: '2020-02-11T22:11:33Z',
                      author: {
                        login: 'iHiD'
                      }
                    }
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

    Github::PullRequest::SyncRepo.('exercism/ruby')

    pr = ::Github::PullRequest.find_by(node_id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4')
    assert_nil pr.author_username
  end

  test "imports pull request that wasn't merged" do
    response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/19',
                id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4',
                createdAt: '2021-02-05T15:29:25Z',
                labels: {
                  nodes: []
                },
                number: 19,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: false,
                mergedAt: nil,
                mergedBy: nil,
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx',
                      submittedAt: '2020-02-15T02:03:01Z',
                      author: {
                        login: 'iHiD'
                      }
                    }
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

    Github::PullRequest::SyncRepo.('exercism/ruby')

    pr = ::Github::PullRequest.find_by(node_id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4')
    assert_nil pr.merged_by_username
  end

  test "imports pull request review without reviewer" do
    response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/19',
                id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4',
                createdAt: '2021-02-05T15:29:25Z',
                labels: {
                  nodes: []
                },
                number: 19,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: true,
                mergedAt: '2020-02-15T02:03:01Z',
                mergedBy: {
                  login: 'iHiD'
                },
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx',
                      submittedAt: '2020-02-09T09:09:09Z',
                      author: nil
                    }
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

    Github::PullRequest::SyncRepo.('exercism/ruby')

    review = ::Github::PullRequestReview.find_by(node_id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx')
    assert_nil review.reviewer_username
  end

  test "fetch all pull requests even if rate limit is reached" do
    first_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/19',
                id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4',
                createdAt: '2021-02-05T15:29:25Z',
                labels: {
                  nodes: []
                },
                number: 19,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: true,
                mergedAt: '2020-02-15T02:03:01Z',
                mergedBy: {
                  login: 'iHiD'
                },
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx',
                      submittedAt: '2020-02-09T21:24:38Z',
                      author: {
                        login: 'iHiD'
                      }
                    }
                  ]
                }
              },
              {
                url: 'https://github.com/exercism/ruby/pull/8',
                id: 'MDExOlB1bGxSZXF1ZXN0NTYzOTgwNTkw',
                createdAt: '2021-01-29T13:20:35Z',
                labels: {
                  nodes: []
                },
                number: 8,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: true,
                mergedAt: '2020-01-31T23:59:58Z',
                mergedBy: {
                  login: 'iHiD'
                },
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg0MzAyODk0',
                      submittedAt: '2020-01-31T22:50:05Z',
                      author: {
                        login: 'ErikSchierboom'
                      }
                    }
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
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/2',
                id: 'MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz',
                createdAt: '2020-03-27T06:39:20Z',
                labels: {
                  nodes: []
                },
                number: 2,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'porkostomus'
                },
                merged: true,
                mergedAt: '2020-04-03T14:54:57Z',
                mergedBy: {
                  login: 'ErikSchierboom'
                },
                reviews: {
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

    Github::PullRequest::SyncRepo.('exercism/ruby')

    assert_equal 3, ::Github::PullRequest.find_each.size
  end

  test "waits for rate limit to reset if rate limit was reached while fetching" do
    first_response = {
      data: {
        repository: {
          nameWithOwner: 'exercism/ruby',
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/19',
                id: 'MDExOlB1bGxSZXF1ZXN0NTY4NDMxMTE4',
                createdAt: '2021-02-05T15:29:25Z',
                labels: {
                  nodes: []
                },
                number: 19,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: true,
                mergedAt: '2020-04-03T14:54:57Z',
                mergedBy: {
                  login: 'iHiD'
                },
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg5NDY1MzEx',
                      submittedAt: '2020-03-27T22:50:05Z',
                      author: {
                        login: 'iHiD'
                      }
                    }
                  ]
                }
              },
              {
                url: 'https://github.com/exercism/ruby/pull/8',
                id: 'MDExOlB1bGxSZXF1ZXN0NTYzOTgwNTkw',
                createdAt: '2021-01-29T13:20:35Z',
                labels: {
                  nodes: []
                },
                number: 8,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'ErikSchierboom'
                },
                merged: true,
                mergedAt: '2020-02-17T16:15:14Z',
                mergedBy: {
                  login: 'iHiD'
                },
                reviews: {
                  nodes: [
                    {
                      id: 'MDE3OlB1bGxSZXF1ZXN0UmV2aWV3NTg0MzAyODk0',
                      submittedAt: '2020-02-05T05:00:01Z',
                      author: {
                        login: 'ErikSchierboom'
                      }
                    }
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
          pullRequests: {
            nodes: [
              {
                url: 'https://github.com/exercism/ruby/pull/2',
                id: 'MDExOlB1bGxSZXF1ZXN0Mzk0NTc4ODMz',
                createdAt: '2020-03-27T06:39:20Z',
                labels: {
                  nodes: []
                },
                number: 2,
                title: "The cat sat on the mat",
                state: 'MERGED',
                author: {
                  login: 'porkostomus'
                },
                merged: true,
                mergedAt: '2020-04-18T18:18:18Z',
                mergedBy: {
                  login: 'ErikSchierboom'
                },
                reviews: {
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
    Github::PullRequest::SyncRepo.('exercism/ruby')
    elapsed = Time.now.utc - start

    assert elapsed > 5.seconds
  end
end
