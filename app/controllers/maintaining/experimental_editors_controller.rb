module Maintaining
  # The editor with experimental features enabled, against a real exercise.
  #
  # This exists so that work which is not ready for students - currently running
  # the tests client-side, on a wasm kernel - can be exercised on production
  # without being exposed to anyone. The flag is what keeps the two apart: the
  # student-facing editor passes `experimental: false` and behaves exactly as it
  # did before, so this page can ship on its own.
  class ExperimentalEditorsController < Maintaining::BaseController
    include CrossOriginIsolation

    # The kernel needs SharedArrayBuffer, which needs cross-origin isolation,
    # which the browser only grants on a real navigation. See the
    # turbo-visit-control meta tag in the view, and Tracks::ExercisesController.
    before_action :cross_origin_isolate!, only: %i[show]

    TRACK_SLUG = 'jq'.freeze

    def index
      @track = track
      @exercises = track.exercises.order(:position)
    end

    def show
      @track = track
      @exercise = track.exercises.find_by!(slug: params[:exercise_slug])

      # Solution::Create refuses to create a solution on a track the user has
      # not joined, so joining is part of opening this page. That is a visible
      # side effect - joined tracks show on a profile - but the alternative is
      # making every maintainer join jq by hand before the page works at all.
      #
      # Asked directly rather than through UserTrack.for, which memoises into
      # Current for the request: a miss there would cache the external track and
      # Solution::Create would still refuse, having joined or not.
      UserTrack::Create.(current_user, @track) unless UserTrack.exists?(user: current_user, track: @track)

      @solution = Solution.find_by(user: current_user, exercise: @exercise) ||
                  Solution::Create.(current_user, @exercise)
    end

    private
    # jq is the only track with a client-side runner published. When there is a
    # second, this becomes a param rather than a constant.
    def track = Track.find_by!(slug: TRACK_SLUG)
  end
end
