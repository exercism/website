# The code sample a track shows in the sign-up code check. Each track opts in
# by adding docs/SIGN_UP_SNIPPET.txt to its repo, so this is blank for a track
# without one.
#
# Each track is cached on its own, keyed on the commit it last synced to, so a
# sync that changes one track's snippet only refreshes that track.
class Track::RetrieveSignUpSnippet
  include Mandate

  initialize_with :track

  def call = Rails.cache.fetch(self.class.cache_key(track)) { track.sign_up_snippet.to_s }

  def self.cache_key(track) = ["track-sign-up-snippet", track.slug, track.synced_to_git_sha]
end
