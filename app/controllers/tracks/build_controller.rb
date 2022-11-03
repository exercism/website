class Tracks::BuildController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_track!
  skip_before_action :authenticate_user!

  def show
    percent = ->(num, denom) { (num.to_f / denom * 100).round(1) }

    @status = @track.build_status

    @test_runner_status_count = @track.submissions.group(:tests_status).count
    @num_test_runs = @test_runner_status_count.values.sum
    @num_submissions = @track.submissions.count
    @num_tests_passed = @test_runner_status_count['passed'].to_i
    @num_tests_failed = @test_runner_status_count['failed'].to_i
    @num_tests_unknown = @num_test_runs - @num_tests_passed - @num_tests_failed
    @percent_tests_passed = percent.(@num_tests_passed, @num_test_runs)
    @percent_tests_failed = percent.(@num_tests_failed, @num_test_runs)
    @percent_tests_unknown = (100 - @percent_tests_passed - @percent_tests_failed).round(1)
    # rubocop:disable Layout/LineLength
    @tooling_statuses = [
      OpenStruct.new(title: "Syllabus", status: 'healthy',
        tooltip_endpoint: Exercism::Routes.syllabus_tooltip_track_build_path(@track)),
      OpenStruct.new(title: "Test-runner", status: "healthy", tooltip_endpoint: Exercism::Routes.test_runner_tooltip_track_build_path(@track)),
      OpenStruct.new(title: "Analyzer", status: 'needs-attention', tooltip_endpoint: Exercism::Routes.analyzer_tooltip_track_build_path(@track)),
      OpenStruct.new(title: "Representer", status: "critical", tooltip_endpoint: Exercism::Routes.representer_tooltip_track_build_path(@track)),
      OpenStruct.new(title: "Practice-exercises", status: "dead", tooltip_endpoint: Exercism::Routes.practice_exercises_tooltip_track_build_path(@track))
    ]
    # rubocop:enable Layout/LineLength
  end

  def syllabus_tooltip = render_template_as_json
  def representer_tooltip = render_template_as_json
  def analyzer_tooltip = render_template_as_json
  def test_runner_tooltip = render_template_as_json
  def practice_exercises_tooltip = render_template_as_json
end
