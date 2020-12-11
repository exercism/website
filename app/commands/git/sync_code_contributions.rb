module Git
  class SyncCodeContributions < Sync
    include Mandate

    def initialize(track)
      super(track, track.synced_to_git_sha)
      @track = track
    end

    def call
      commits_from_current_to_head.each do |commit|
        user = User.find_by(github_username: commit.author[:email])

        # TODO: decide what to do with user that cannot be found
        next unless user

        commit_link = "#{track.repo_url}/commit/#{commit.oid}"
        User::ReputationToken::CodeContribution::Create.(user, commit_link)
      end
    end

    private
    attr_reader :track
  end
end
