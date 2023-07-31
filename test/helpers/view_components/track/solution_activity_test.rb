require "test_helper"

class ViewComponents::Track::SolutionActivityTest < ActionView::TestCase
  include IconsHelper

  test "started" do
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track:, slug: 'bob'
    solution = create(:concept_solution, exercise:)
    user_track = create :user_track, track:, user: solution.user

    comp = render(ViewComponents::Track::SolutionActivity.new(solution, user_track))
    expected = <<~HTML
      <div class="exercise">
        <header>
          <a class="content" href="https://test.exercism.org/tracks/ruby/exercises/bob">
          #{render ReactComponents::Common::ExerciseWidget.new(
            exercise, user_track, solution:,
            render_as_link: false, render_blurb: false, render_track: false
          )}
          </a>

          #{render ReactComponents::Student::OpenEditorButton.new(exercise, user_track)}
        </header>
      </div>
    HTML

    assert_html_equal expected, comp.to_s
  end

  test "with iteration" do
    skip # TODO: Implement this test. System test?

    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track:, slug: 'bob'
    solution = create(:concept_solution, exercise:)
    iteration = create(:iteration, solution:)
    user_track = UserTrack::Exernal.new(track)

    expected = link_to(
      track_exercise_iterations_path(track, exercise, idx: solution.latest_iteration.idx),
      class: 'latest-iteration'
    ) do
      render(ReactComponents::Track::IterationSummary.new(iteration, slim: true).to_s) +
        graphical_icon('chevron-right', css_class: "action-icon")
    end

    actual = render ViewComponents::Track::SolutionActivity.new(solution, user_track).to_s
    assert_includes actual, expected
  end

  test "with mentor comments to_hash" do
    skip # TODO: Implement this test. System test?
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track:, slug: 'bob'
    solution = create(:concept_solution, exercise:)
    create(:iteration, solution:)
    discussion = create(:mentor_discussion, solution:)
    user_track = UserTrack::Exernal.new(track)

    comp = render ViewComponents::Track::SolutionActivity.new(solution.reload, user_track)
    p comp.to_s
    # assert_include expected, comp.to_s

    create :mentor_discussion_post, discussion:, seen_by_student: true
    comp = render ViewComponents::Track::SolutionActivity.new(solution.reload, user_track)
    p comp.to_s
    # assert_include expected, comp.to_s

    create :mentor_discussion_post, discussion:, seen_by_student: false
    comp = render ViewComponents::Track::SolutionActivity.new(solution.reload, user_track)
    p comp.to_s
    # assert_include expected, comp.to_s
  end
end
