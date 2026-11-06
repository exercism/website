# The tracks offered in the sign-up code check. A track only appears once its
# repo has a sign-up snippet.
#
# This reads every track's snippet cache in one round trip. Only the tracks
# missing from the cache are read from git, and those are cached individually.
#
# The three tracks with the most students come first. The rest follow in
# alphabetical order.
class Track::RetrieveSignUpCodeCheckTracks
  include Mandate

  NUM_POPULAR = 3

  def call
    keyed = tracks.index_by { |track| Track::RetrieveSignUpSnippet.cache_key(track) }
    snippets = Rails.cache.fetch_multi(*keyed.keys) { |key| keyed[key].sign_up_snippet.to_s }

    keyed.filter_map { |key, track| track if snippets[key].present? }
  end

  private
  def tracks
    by_popularity = Track.active.order(num_students: :desc).to_a
    popular = by_popularity.first(NUM_POPULAR)
    popular + (by_popularity - popular).sort_by { |track| track.title.downcase }
  end
end
