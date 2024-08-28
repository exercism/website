class Track::RetrieveMaintainersStatus
  include Mandate

  def call
    { Track.for!('csharp') =>
  { active: [{ handle: "erikSchierboom", github_username: "ErikSchierboom", reputation: 6130 }],
    inactive: [],
    candidates: [{ handle: "iHiD", github_username: "iHiD", reputation: 60 },
                 { handle: "dem4ron", github_username: "dem4ron", reputation: 3 }],
    unlinked: ["wolf99"] },
      Track.for!("elixir") =>
  { active: [],
    inactive: [],
    candidates: [{ handle: "erikSchierboom", github_username: "ErikSchierboom", reputation: 393 },
                 { handle: "iHiD", github_username: "iHiD", reputation: 65 },
                 { handle: "meatball", github_username: "meatball133", reputation: 29 }],
    unlinked: %w[Cohen-Carlisle angelikatyborska neenjaw Br1ght0ne jiegillet] },
      Track.for!("javascript") =>
  { active: [],
    inactive: [],
    candidates: [{ handle: "erikSchierboom", github_username: "ErikSchierboom", reputation: 375 },
                 { handle: "iHiD", github_username: "iHiD", reputation: 96 },
                 { handle: "dem4ron", github_username: "dem4ron", reputation: 12 }],
    unlinked: %w[joshgoebel IsaacG tejasbubane SleeplessByte junedev] },
      Track.for!("prolog") =>
  { active: [],
    inactive: [],
    candidates: [{ handle: "erikSchierboom", github_username: "ErikSchierboom", reputation: 1803 },
                 { handle: "iHiD", github_username: "iHiD", reputation: 12 }],
    unlinked: ["Average-user"] } }
  end
end

# def fetch_track_team_members(track_slugs)
#   query = <<~GRAPHQL
#   query ($endCursor: String) {
#     organization(login: "exercism") {
#       team(slug: "track-maintainers") {
#         childTeams(after: $endCursor, first: 100) {
#           nodes {
#             name
#             members(first: 100) {
#               nodes {
#                 login
#               }
#             }
#           }
#           pageInfo {
#             endCursor
#             hasNextPage
#           }
#         }
#       }
#     }
#   }
#   GRAPHQL

#   response = Github::Graphql::ExecuteQuery.(query, %i[organization team childTeams])
#   response[0][:nodes].filter_map do |node|
#     next unless track_slugs.include?(node[:name])

#     [node[:name], node.dig(:members, :nodes).pluck(:login)]
#   end.sort.to_h
# end

# LAST_NUMBER_OF_MONTHS_FOR_REP = 9

# def fetch_track_contributors(track_slugs)
#   rep_cutoff_date = Time.now.to_date - LAST_NUMBER_OF_MONTHS_FOR_REP.months

#   track_slugs.map do |track_slug|
#     users_rep = User::ReputationToken.
#             includes(user: :data).
#             joins(:track).
#             where('tracks.slug': track_slug).
#             where(category: :building).
#             where('user_reputation_tokens.created_at > ?', rep_cutoff_date).
#             group(:user).
#             sum(:value).
#             map {|user, reputation| { handle: user.handle, github_username: user.data&.github_username, reputation:}}.
#             sort_by {|data| -data[:reputation]}

#     [track_slug, users_rep]
#   end.to_h
# end

# MIN_REP = 1

# def fetch_tracks
#   slugs = Track.active.map(&:slug)
#   track_team_members = fetch_track_team_members(slugs)
#   track_contributors = fetch_track_contributors(slugs)

#   slugs.map do |slug|
#     contributors = track_contributors[slug].to_a
#     team_members = track_team_members[slug].to_a

#     linked_members, unlinked_members = team_members.partition do |github_username|
#       contributors.find {|data| data[:github_username] == github_username}
#     end

#     users = { active: [], inactive: [], candidates: [], unlinked: unlinked_members }
#     contributors.each do |contributor|
#       if team_members.include?(contributor[:github_username])
#         if contributor[:reputation] >= MIN_REP
#           users[:active] << contributor
#         else
#           users[:inactive] << contributor
#         end
#       else
#         users[:candidates] << contributor
#       end
#     end

#     [slug, users]
#   end.to_h
# end
