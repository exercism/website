class Track::RetrieveMaintainersStatus
  include Mandate

  MIN_REP_FOR_MEMBER = 50
  MIN_REP_FOR_CANDIDATE = 100
  LAST_NUMBER_OF_MONTHS_FOR_REP = 9
  CACHE_KEY = "Track::RetrieveMaintainersStatus".freeze

  def call
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
      tracks.index_with { |track| track_maintainers(track) }
    end
  end

  private
  def track_maintainers(track)
    contributors = track_contributors[track.slug].to_a
    team_members = track_team_members[track.slug].to_a

    maintainers = { active: [], inactive: [], candidates: [], contributors: [], unlinked: [] }

    contributors.each do |contributor|
      if team_members.include?(contributor[:github_username])
        category = contributor[:reputation] >= MIN_REP_FOR_MEMBER ? :active : :inactive
      else
        category = contributor[:reputation] >= MIN_REP_FOR_CANDIDATE ? :candidates : :contributors
      end

      maintainers[category] << contributor
    end

    team_members.each do |github_username|
      handle = contributors_github_username_to_handle[github_username]

      if handle.nil?
        maintainers[:unlinked] << { github_username: }
      elsif contributors.none? { |m| m[:handle] == handle }
        maintainers[:inactive] << { handle:, github_username:, reputation: 0 }
      end
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
    response.flat_map do |nodes|
      nodes[:nodes].filter_map do |node|
        next unless track_slugs.include?(node[:name])

        [node[:name], node.dig(:members, :nodes).pluck(:login)]
      end
    end.sort.to_h
  end

  memoize
  def track_contributors
    track_slugs.index_with do |track_slug|
      User::ReputationToken.
        includes(user: :data).
        joins(:track).
        where('tracks.slug': track_slug).
        where(category: %i[authoring building maintaining]).
        where('user_reputation_tokens.created_at > ?', rep_cutoff_date).
        group(:user).
        sum(:value).
        map { |user, reputation| { handle: user.handle, github_username: user.data&.github_username, reputation: } }.
        sort_by { |data| -data[:reputation] }
    end
  end

  memoize
  def contributors_github_username_to_handle
    usernames = track_team_members.values.flatten.uniq
    User::Data.joins(:user).
      where(github_username: usernames).
      pluck(:github_username, :handle).
      to_h
  end

  memoize
  def tracks = Track.active.order(:title)

  memoize
  def track_slugs = tracks.pluck(:slug)

  memoize
  def rep_cutoff_date = Time.zone.today - LAST_NUMBER_OF_MONTHS_FOR_REP.months

  CACHE_EXPIRY = 1.day.freeze
  private_constant :CACHE_EXPIRY
end
