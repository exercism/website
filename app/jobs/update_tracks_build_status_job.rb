class UpdateTracksBuildStatusJob < ApplicationJob
  queue_as :metrics

  def perform
    Git::ProblemSpecifications.update!

    tracks.find_each do |track|
      Track::UpdateBuildStatus.(track)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  private
  def tracks = Track.where.not(slug: EXCLUDED_SLUGS)

  EXCLUDED_SLUGS = %w[javascript-legacy].freeze
  private_constant :EXCLUDED_SLUGS
end
