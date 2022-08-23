require "test_helper"

class Github::Repository::UpdateBranchProtectionTest < ActiveSupport::TestCase
  test "sets correct branch protection for active track's repo" do
    create :track, slug: 'elixir', active: true

    stub_request(:get, "https://api.github.com/repos/exercism/elixir/branches/main/protection").
      to_return(status: 200, body: current_branch_protection_settings.to_json, headers: { 'Content-Type': 'application/json' })

    stub_request(:put, "https://api.github.com/repos/exercism/elixir/branches/main/protection").
      with(body: hash_including({
        required_status_checks: {
          strict: false,
          checks: [{ context: "configlet / configlet", app_id: 15_368 }]
        },
        enforce_admins: false,
        required_pull_request_reviews: {
          dismissal_restrictions: {},
          dismiss_stale_reviews: false,
          require_code_owner_reviews: true,
          required_approving_review_count: 1,
          bypass_pull_request_allowances: {
            users: [],
            teams: []
          }
        },
        # restrictions: nil,
        required_linear_history: false,
        allow_force_pushes: false,
        allow_deletions: false,
        block_creations: false,
        required_conversation_resolution: false
      }), headers: { 'Content-Type': 'application/json' }).
      to_return(status: 200)

    repos = [Github::Repository.new('elixir', :track)]
    Github::Repository::UpdateBranchProtection.(repos)
  end

  private
  def current_branch_protection_settings
    {
      required_status_checks: {
        strict: false,
        checks: []
      },
      required_pull_request_reviews: {
        dismiss_stale_reviews: true,
        require_code_owner_reviews: true,
        required_approving_review_count: 1
      },
      required_signatures: { enabled: false },
      enforce_admins: { enabled: false },
      required_linear_history: { enabled: false },
      allow_force_pushes: { enabled: false },
      allow_deletions: { enabled: false },
      block_creations: { enabled: false },
      required_conversation_resolution: { enabled: false }
    }
  end

  def new_branch_protection_settings
    {
      # required_status_checks: {
      #   strict: false,
      #   # checks:
      # },
      enforce_admins: false # We want admins to be able to override things
      # required_pull_request_reviews: {
      #   dismissal_restrictions: {},
      #   dismiss_stale_reviews: false,
      #   require_code_owner_reviews: true, # We want to enforce code owner reviews
      #   # required_approving_review_count:,
      #   bypass_pull_request_allowances: {
      #     users: [], # Disallow bypassing PR allowances for users
      #     teams: [] # Disallow bypassing PR allowances for teams
      #   }
      # },
      # restrictions: nil,
      # # required_linear_history:,
      # allow_force_pushes: false, # We want to disable force pushing
      # allow_deletions: false, # Don't allow deleting the branch
      # block_creations: false,
      # required_conversation_resolution: false
    }

    # {
    #   required_status_checks: {
    #     strict:false,
    #     checks:[
    #       {context:"configlet",app_id:15368},
    #       {context:"configlet / configlet",app_id:15368}
    #     ]
    #   },
    #   enforce_admins:false,
    #   required_pull_request_reviews:{
    #     dismissal_restrictions:{},
    #     dismiss_stale_reviews:false,
    #     require_code_owner_reviews:true,
    #     required_approving_review_count:1,
    #     bypass_pull_request_allowances:{
    #       users:[],teams:[]
    #     }
    #   },
    #   restrictions:nil,
    #   required_linear_history:true,
    #   allow_force_pushes:false,
    #   allow_deletions:false,
    #   block_creations:false,
    #   required_conversation_resolution:false
    # }
  end
end
