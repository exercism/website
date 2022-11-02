class TracksController < ApplicationController
  before_action :use_track, except: :index
  skip_before_action :authenticate_user!, only: %i[index show about]

  def index
    @tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    @num_tracks = Track.active.count

    # TODO: (Optional) Change this to only select the fields needed for an icon
    @track_icon_urls = Track.active.order('rand()').limit(8).map(&:icon_url)
  end

  def about
    return redirect_to action: :show if @user_track.external?

    setup_about
  end

  def build
    percent = ->(num, denom) { (num.to_f / denom * 100).round(1) }

    @test_runner_status_count = @track.submissions.group(:tests_status).count
    @num_test_runs = @test_runner_status_count.values.sum
    @num_submissions = @track.submissions.count
    @num_tests_passed = @test_runner_status_count['passed']
    @num_tests_failed = @test_runner_status_count['failed']
    @num_tests_unknown = @num_test_runs - @num_tests_passed - @num_tests_failed
    @percent_tests_passed = percent.(@num_tests_passed, @num_test_runs)
    @percent_tests_failed = percent.(@num_tests_failed, @num_test_runs)
    @percent_tests_unknown = (100 - @percent_tests_passed - @percent_tests_failed).round(1)
    # rubocop:disable Layout/LineLength
    @tooling_statuses = [
      OpenStruct.new(title: "Syllabus", status: 'healthy',
        tooltip_endpoint: Exercism::Routes.syllabus_tooltip_track_path(@track)),
      OpenStruct.new(title: "Test-runner", status: "healthy", tooltip_endpoint: Exercism::Routes.test_runner_tooltip_track_path(@track)),
      OpenStruct.new(title: "Analyzer", status: 'needs-attention', tooltip_endpoint: Exercism::Routes.analyzer_tooltip_track_path(@track)),
      OpenStruct.new(title: "Representer", status: "critical", tooltip_endpoint: Exercism::Routes.representer_tooltip_track_path(@track)),
      OpenStruct.new(title: "Practice-exercises", status: "dead", tooltip_endpoint: Exercism::Routes.practice_exercises_tooltip_track_path(@track))
    ]
    # rubocop:enable Layout/LineLength
  end

  def syllabus_tooltip = render_template_as_json
  def representer_tooltip = render_template_as_json
  def analyzer_tooltip = render_template_as_json
  def test_runner_tooltip = render_template_as_json
  def practice_exercises_tooltip = render_template_as_json

  def show
    if @user_track.external?
      setup_about

      return render "tracks/about"
    end

    # TODO: (Optional) Move this into a method somewhere else and add tests
    data = @user_track.solutions.
      where('completed_at > ?', Time.current.beginning_of_week - 8.weeks).
      group("week(completed_at)").count
    current_week = Date.current.cweek
    @last_8_weeks_counts = ((current_week - 8)...current_week).to_a.map { |w| (w % 53) + 1 }.map { |w| data.fetch(w, 0) }

    @recent_solutions = UserTrack::RetrieveRecentlyActiveSolutions.(@user_track)
    @updates = SiteUpdate.published.for_track(@track).sorted.limit(10)
  end

  def join
    UserTrack::Create.(current_user, @track)
    redirect_to action: :show
  end

  private
  def use_track
    @track = Track.find(params[:id])
    @user_track = UserTrack.for(current_user, @track)

    render_404 unless @track.accessible_by?(current_user)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def setup_about
    @showcase_exercises = @user_track.exercises.order("RAND()").limit(3).to_a
  end
end
