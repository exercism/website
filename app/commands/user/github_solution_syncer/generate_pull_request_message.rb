class User::GithubSolutionSyncer
  class GeneratePullRequestMessage
    include Mandate

    initialize_with :user, :description

    def call
      <<~MSG
        #{description % { handle: }}

        It has been automatically generated at the request of #{user.handle} using Exercism's GitHub Solution Syncer tool.

        ---

        _[Exercism](https://exercism.org) is a leading non-profit coding education platform. We help people from all over the world learn and practice over 75 different programming languages for free! 🚀_
      MSG
    end

    def handle
      user.profile? ? "[#{user.handle}](#{Exercism::Routes.profile_url(user)})" : user.handle
    end
  end
end
