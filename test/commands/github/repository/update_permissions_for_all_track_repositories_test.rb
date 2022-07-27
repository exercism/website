require "test_helper"

class Github::Repository::UpdatePermissionsForAllTrackRepositoriesTest < ActiveSupport::TestCase
  test "updates branch protections of active tracks" do
    # active_track_1 = create :track, :random_slug, active: true
    # active_track_2 = create :track, :random_slug, active: true
    # inactive_track = create :track, :random_slug, active: false

    Github::Repository::UpdatePermissionsForAllTrackRepositories.()
  end
end
