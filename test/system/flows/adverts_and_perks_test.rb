require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class CompleteExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "advert impression logged" do
      travel_to(Time.zone.local(2023, 8, 18, 12, 0)) do
        ActionDispatch::Request.any_instance.expects(:is_crawler?).returns(false)

        track = create :track, slug: :javascript
        exercise = create(:practice_exercise, track:)
        advert = create :advert, status: :active

        perform_enqueued_jobs do
          visit track_exercise_url(track, exercise)
        end

        assert_equal 1, advert.reload.num_impressions
      end
    end
  end
end
