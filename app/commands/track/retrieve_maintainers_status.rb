class Track::RetrieveMaintainersStatus
  include Mandate

  MIN_REP_FOR_MEMBER = 50
  MIN_REP_FOR_CANDIDATE = 100
  LAST_NUMBER_OF_MONTHS_FOR_REP = 9

  def call
    Rails.cache.fetch("Track::RetrieveMaintainersStatus/1", expires_in: 1.day) do
      tracks.index_with { |track| track_maintainers(track) }
    end
  end

  private
  def track_maintainers(track)
    contributors = track_contributors[track.slug].to_a
    team_members = track_team_members[track.slug].to_a
    unlinked = team_members & unlinked_github_usernames

    maintainers = { active: [], inactive: [], candidates: [], contributors: [], unlinked: }
    contributors.each do |contributor|
      if team_members.include?(contributor[:github_username])
        category = contributor[:reputation] >= MIN_REP_FOR_MEMBER ? :active : :inactive
      else
        category = contributor[:reputation] >= MIN_REP_FOR_CANDIDATE ? :candidates : :contributors
      end

      maintainers[category] << contributor
    end

    maintainers
  end

  memoize
  def track_team_members
    query = <<~GRAPHQL
      query ($endCursor: String) {
        organization(login: "exercism") {
          team(slug: "track-maintainers") {
            childTeams(after: $endCursor, first: 100) {
              nodes {
                name
                members(first: 100) {
                  nodes {
                    login
                  }
                }
              }
              pageInfo {
                endCursor
                hasNextPage
              }
            }
          }
        }
      }
    GRAPHQL

    response = Github::Graphql::ExecuteQuery.(query, %i[organization team childTeams])
    response[0][:nodes].filter_map do |node|
      next unless track_slugs.include?(node[:name])

      [node[:name], node.dig(:members, :nodes).pluck(:login)]
    end.to_h
  end

  memoize
  def track_contributors
    track_slugs.index_with do |track_slug|
      User::ReputationToken.
        includes(user: :data).
        joins(:track).
        where('tracks.slug': track_slug).
        where(category: :building).
        where('user_reputation_tokens.created_at > ?', rep_cutoff_date).
        group(:user).
        sum(:value).
        map { |user, reputation| { handle: user.handle, github_username: user.data&.github_username, reputation: } }.
        sort_by { |data| -data[:reputation] }
    end
  end

  memoize
  def unlinked_github_usernames
    usernames = track_team_members.values.flatten.uniq
    linked = User::Data.
      where(github_username: usernames).
      pluck(:github_username)
    usernames - linked
  end

  memoize
  def tracks = Track.active.order(:title)

  memoize
  def track_slugs = tracks.pluck(:slug)

  memoize
  def rep_cutoff_date = Time.zone.today - LAST_NUMBER_OF_MONTHS_FOR_REP.months
end
