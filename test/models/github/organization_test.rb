require "test_helper"

class Github::OrganizationTest < ActiveSupport::TestCase
  test "remove_member" do
    skip # enable once organization functionality has been tested properly
    Github::Organization.instance.stubs(:name).returns('exercism')

    stub_request(:delete, "https://api.github.com/orgs/exercism/members/erikschierboom").
      to_return(status: 200, body: "", headers: {})

    Github::Organization.instance.remove_member('erikschierboom')
  end

  # TODO: remove once organization functionality has been tested properly
  test "remove_member (temp)" do
    Github::Organization.instance.stubs(:name).returns('exercism')

    Github::Issue::OpenForOrganizationMemberRemove.expects(:call).with('exercism', 'erikschierboom')

    Github::Organization.instance.remove_member('erikschierboom')
  end

  test "team_membership_count_for_user" do
    response = {
      data: {
        organization: {
          teams: {
            totalCount: 2
          }
        }
      }
    }

    stub_request(:post, "https://api.github.com/graphql").
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

    membership_count = Github::Organization.instance.team_membership_count_for_user('erikschierboom')
    assert_equal 2, membership_count
  end

  test "member_usernames" do
    response = {
      data: {
        organization: {
          membersWithRole: {
            nodes: [
              { login: 'ErikSchierboom' },
              { login: 'iHiD' }
            ]
          },
          pageInfo: {
            hasNextPage: false,
            endCursor: "Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR"
          }
        },
        rateLimit: {
          remaining: 4989,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    stub_request(:post, "https://api.github.com/graphql").
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

    assert_equal %w[ErikSchierboom iHiD], Github::Organization.instance.member_usernames.to_a
  end

  test "team_member_usernames" do
    response = {
      data: {
        organization: {
          teams: {
            nodes: [
              {
                name: 'ruby',
                members: {
                  nodes: [
                    { login: 'ErikSchierboom' },
                    { login: 'iHiD' }
                  ]
                }
              },
              {
                name: 'fsharp',
                members: {
                  nodes: [
                    { login: 'ErikSchierboom' },
                    { login: 'DJ' }
                  ]
                }
              }
            ]
          },
          pageInfo: {
            hasNextPage: false,
            endCursor: "Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR"
          }
        },
        rateLimit: {
          remaining: 4989,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    stub_request(:post, "https://api.github.com/graphql").
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

    assert_equal %w[ErikSchierboom iHiD DJ], Github::Organization.instance.team_member_usernames.to_a
  end

  test "team_members" do
    response = {
      data: {
        organization: {
          teams: {
            nodes: [
              {
                name: 'ruby',
                members: {
                  nodes: [
                    { databaseId: 142_153 },
                    { databaseId: 123_813 }
                  ]
                }
              },
              {
                name: 'fsharp',
                members: {
                  nodes: [
                    { databaseId: 142_153 },
                    { databaseId: 229_136 }
                  ]
                }
              }
            ]
          },
          pageInfo: {
            hasNextPage: false,
            endCursor: "Y3Vyc29yOnYyOpK5MjAyMC0wMy0yN1QwNzozOToyMCswMTowMM4XhMuR"
          }
        },
        rateLimit: {
          remaining: 4989,
          resetAt: '2021-03-10T15:32:50Z'
        }
      }
    }

    stub_request(:post, "https://api.github.com/graphql").
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type': 'application/json' })

    expected = { 'ruby' => [142_153, 123_813], 'fsharp' => [142_153, 229_136] }
    assert_equal expected, Github::Organization.instance.team_members.to_h
  end
end
