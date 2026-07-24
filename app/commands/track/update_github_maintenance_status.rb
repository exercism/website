# Keeps a track repo's GitHub `maintained`/`unmaintained` topic in sync with
# whether the track has any maintainers on its GitHub team. Those topics drive
# the automated "this repo is unmaintained" PR comments (see the
# ping-cross-track-maintainers-team workflow), so promoting a track the moment
# it gains a maintainer silences them without any manual intervention.
#
# We only ever toggle the plain `maintained` <-> `unmaintained` pair. The
# nuanced categories (`wip-track`, `maintained-autonomous`, `maintained-solitary`)
# are deliberate admin choices, so we leave them untouched.
class Track::UpdateGithubMaintenanceStatus
  include Mandate

  initialize_with :track

  def call
    return if Rails.env.development?
    return unless new_topic

    Exercism.octokit_client.replace_all_topics(repo, (current_topics - TOGGLEABLE) + [new_topic])
  end

  private
  memoize
  def new_topic
    if maintained?
      MAINTAINED if current_topics.include?(UNMAINTAINED)
    elsif current_topics.include?(MAINTAINED)
      UNMAINTAINED
    end
  end

  def maintained? = track.github_team_members.exists?

  memoize
  def current_topics = Exercism.octokit_client.topics(repo).names

  def repo = "exercism/#{track.slug}"

  MAINTAINED = "maintained".freeze
  UNMAINTAINED = "unmaintained".freeze
  TOGGLEABLE = [MAINTAINED, UNMAINTAINED].freeze
  private_constant :MAINTAINED, :UNMAINTAINED, :TOGGLEABLE
end
