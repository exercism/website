require "test_helper"

# rubocop:disable Layout/LineLength
class ViewComponents::Track::SolutionActivityTest < ActionView::TestCase
  include IconsHelper
  include Webpacker::Helper

  test "started" do
    track = create :track, slug: 'ruby'
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise
    user_track = create :user_track, track: track, user: solution.user

    comp = render(ViewComponents::Track::SolutionActivity.new(solution, user_track))
    expected = <<~HTML
      <div class="exercise">
        <header>
          <a class="content" href="https://test.exercism.io/tracks/ruby/exercises/bob">
            <img alt=\"Bob\" class=\"c-icon c-exercise-icon \" onerror=\"if (this.src != &#39;http://test.host/packs-test/media/images/graphics/missing-exercise-edf3eecaaf596fb574782fa08467149d.svg&#39;) this.src = &#39;http://test.host/packs-test/media/images/graphics/missing-exercise-edf3eecaaf596fb574782fa08467149d.svg&#39;;\" src=\"https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/exercises/bob.svg\" />
            <div class="info">
              <div class="title">Bob</div>
              <div class="tags">
                <div class="c-exercise-status-tag --started">Started</div>
              </div>
            </div>
          </a>

          <div class="c-combo-button">
            <a class="--primary-segment" href="/tracks/ruby/exercises/bob/edit">Continue in Editor</a>
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
    exercise = create :concept_exercise, track: track, slug: 'bob'
    solution = create :concept_solution, exercise: exercise
    create :iteration, solution: solution
    discussion = create :mentor_discussion, solution: solution
    user_track = UserTrack::Exernal.new(track)

    comp = render ViewComponents::Track::SolutionActivity.new(solution.reload, user_track)
    p comp.to_s
    # assert_include expected, comp.to_s

    create :mentor_discussion_post, discussion: discussion, seen_by_student: true
    comp = render ViewComponents::Track::SolutionActivity.new(solution.reload, user_track)
    p comp.to_s
    # assert_include expected, comp.to_s

    create :mentor_discussion_post, discussion: discussion, seen_by_student: false
    comp = render ViewComponents::Track::SolutionActivity.new(solution.reload, user_track)
    p comp.to_s
    # assert_include expected, comp.to_s
  end
end
# rubocop:enable Layout/LineLength
