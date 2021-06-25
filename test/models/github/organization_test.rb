require "test_helper"

class Github::OrganizationTest < ActiveSupport::TestCase
  # TODO: enable tests

  # test "adds new members" do
  #   response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'ErikSchierboom' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: false,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4991,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   RestClient.unstub(:post)
  #   stub_request(:post, "https://api.github.com/graphql").
  #     to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

  #   Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])

  #   Github::OrganizationMember::SyncMembers.()

  #   member = ::Github::OrganizationMember.find_by(username: 'ErikSchierboom')
  #   refute member.alumnus
  # end

  # test "keeps existing members" do
  #   create :github_organization_member, username: 'ErikSchierboom'

  #   response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'ErikSchierboom' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: false,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4991,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   RestClient.unstub(:post)
  #   stub_request(:post, "https://api.github.com/graphql").
  #     to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

  #   Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom'])

  #   Github::OrganizationMember::SyncMembers.()

  #   member = ::Github::OrganizationMember.find_by(username: 'ErikSchierboom')
  #   refute member.alumnus
  # end

  # test "makes missing members alumnus" do
  #   member = create :github_organization_member, username: 'iHiD'

  #   response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'ErikSchierboom' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: false,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4991,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom', 'iHiD'])

  #   RestClient.unstub(:post)
  #   stub_request(:post, "https://api.github.com/graphql").
  #     to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

  #   Github::OrganizationMember::SyncMembers.()

  #   assert member.reload.alumnus
  # end

  # test "imports all members" do
  #   first_response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'ErikSchierboom' },
  #             { login: 'iHiD' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: true,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4991,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   second_response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'DJ' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: false,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4989,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   RestClient.unstub(:post)
  #   stub_request(:post, "https://api.github.com/graphql").
  #     with { |request| !request.body.include?("after:") }.
  #     to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

  #   stub_request(:post, "https://api.github.com/graphql").
  #     with { |request| request.body.include?("after: \\\"Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp\\\"") }.
  #     to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

  #   Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom', 'DJ', 'iHiD'])

  #   Github::OrganizationMember::SyncMembers.()

  #   members = ::Github::OrganizationMember.all
  #   assert_equal 3, members.size
  #   assert_equal 'ErikSchierboom', members.first.username
  #   assert_equal 'iHiD', members.second.username
  #   assert_equal 'DJ', members.third.username
  # end

  # test "imports all members even if rate limit is reached" do
  #   first_response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'ErikSchierboom' },
  #             { login: 'iHiD' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: true,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 0,
  #         resetAt: 5.seconds.from_now.utc.iso8601
  #       }
  #     }
  #   }

  #   second_response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'DJ' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: false,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4989,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   RestClient.unstub(:post)
  #   stub_request(:post, "https://api.github.com/graphql").
  #     with { |request| !request.body.include?("after:") }.
  #     to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

  #   stub_request(:post, "https://api.github.com/graphql").
  #     with { |request| request.body.include?("after: \\\"Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp\\\"") }.
  #     to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

  #   Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom', 'DJ', 'iHiD'])

  #   Github::OrganizationMember::SyncMembers.()

  #   assert_equal 3, ::Github::OrganizationMember.find_each.size
  # end

  # test "waits for rate limit to reset if rate limit was reached while fetching" do
  #   first_response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'ErikSchierboom' },
  #             { login: 'iHiD' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: true,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 0,
  #         resetAt: 5.seconds.from_now.utc.iso8601
  #       }
  #     }
  #   }

  #   second_response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'DJ' }
  #           ],
  #           pageInfo: {
  #             hasNextPage: false,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4989,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   RestClient.unstub(:post)
  #   stub_request(:post, "https://api.github.com/graphql").
  #     with { |request| !request.body.include?("after:") }.
  #     to_return(status: 200, body: first_response.to_json, headers: { 'Content-Type': 'application/json' })

  #   stub_request(:post, "https://api.github.com/graphql").
  #     with { |request| request.body.include?("after: \\\"Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp\\\"") }.
  #     to_return(status: 200, body: second_response.to_json, headers: { 'Content-Type': 'application/json' })

  #   Github::Organization.any_instance.stubs(:team_member_usernames).returns(['ErikSchierboom', 'DJ', 'iHiD'])

  #   start = Time.current
  #   Github::OrganizationMember::SyncMembers.()
  #   elapsed = Time.current - start

  #   assert elapsed > 5.seconds
  # end

  # test "removes members without team membership from organization" do
  #   create :github_organization_member, username: 'DJ'
  #   create :github_organization_member, username: 'ErikSchierboom'
  #   create :github_organization_member, username: 'iHiD'

  #   Github::Organization.any_instance.stubs(:member_usernames).returns()
  #   members_response = {
  #     data: {
  #       organization: {
  #         membersWithRole: {
  #           nodes: [
  #             { login: 'DJ' },
  #             { login: 'ErikSchierboom' },
  #             { login: 'iHiD' }

  #   team_members_response = {
  #     data: {
  #       organization: {
  #         teams: {
  #           nodes: [
  #             {
  #               members: {
  #                 nodes: [
  #                   { login: 'DJ' }
  #                 ]
  #               }
  #             }
  #           ],
  #           pageInfo: {
  #             hasNextPage: false,
  #             endCursor: 'Y3Vyc29yOnYyOpK5MjAxOS0wMS0yMVQxNDo0OTo0MCswMTowMM4Orjsp'
  #           }
  #         }
  #       },
  #       rateLimit: {
  #         remaining: 4991,
  #         resetAt: '2021-03-10T15:32:50Z'
  #       }
  #     }
  #   }

  #   stub_request(:post, "https://api.github.com/graphql").
  #     with { |request| request.body.include?("teams") }.
  #     to_return(status: 200, body: team_members_response.to_json, headers: { 'Content-Type': 'application/json' })

  #   Github::OrganizationMember::SyncMembers.()

  # end
end
