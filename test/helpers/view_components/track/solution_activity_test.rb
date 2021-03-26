require "test_helper"

# rubocop:disable Layout/LineLength
class ViewComponents::Track::SolutionActivityTest < ActionView::TestCase
  include IconsHelper
  include Webpacker::Helper

  test "started" do
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise

    comp = render ViewComponents::Track::SolutionActivity.new(track, solution)
    expected = <<~HTML
            <div class="exercise">
              <header>
                <a class="content" href="https://test.exercism.io/tracks/ruby/exercises/bob">
                  #{exercise_icon(exercise)}
                  <div class="info">
                    <div class="title">Bob</div>
                    <div class="tags">
                      <div class="c-exercise-status-tag --started">Started</div>
                    </div>
                  </div>
                </a>
      #{'      '}
                <div class="c-combo-button">
                  <a class="--editor-segment" href="/tracks/ruby/exercises/bob/edit">Continue in Editor</a>
                  <div class="--dropdown-segment">
                    #{graphical_icon('chevron-down')}
                  </div>
                </div>
              </header>
            </div>
    HTML

    assert_html_equal expected, comp.to_s
  end

  test "with iteration" do
    skip # TODO: Implement this test. System test?

    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise
    iteration = create :iteration, solution: solution

    expected = link_to(
      track_exercise_iterations_path(track, exercise, idx: solution.latest_iteration.idx),
      class: 'latest-iteration'
    ) do
      render(ReactComponents::Track::IterationSummary.new(iteration, slim: true).to_s) +
        graphical_icon('chevron-right', css_class: "action-icon")
    end

    actual = render ViewComponents::Track::SolutionActivity.new(track, solution).to_s
    assert_includes actual, expected
  end

  test "with mentor comments to_hash" do
    skip # TODO: Implement this test. System test?
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise
    create :iteration, solution: solution
    discussion = create :mentor_discussion, solution: solution

    comp = render ViewComponents::Track::SolutionActivity.new(track, solution.reload)
    p comp.to_s
    # assert_include expected, comp.to_s

    create :mentor_discussion_post, discussion: discussion, seen_by_student: true
    comp = render ViewComponents::Track::SolutionActivity.new(track, solution.reload)
    p comp.to_s
    # assert_include expected, comp.to_s

    create :mentor_discussion_post, discussion: discussion, seen_by_student: false
    comp = render ViewComponents::Track::SolutionActivity.new(track, solution.reload)
    p comp.to_s
    # assert_include expected, comp.to_s
  end
end
# rubocop:enable Layout/LineLength
