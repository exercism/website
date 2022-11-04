class UpdateTracksBuildStatusJob < ApplicationJob
  queue_as :metrics

  def perform
    Git::ProblemSpecifications.update!
    Track.find_each do |track|
      Track::UpdateBuildStatus.(track)
    end
  end
end
