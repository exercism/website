require "test_helper"

# rubocop:disable Layout/LineLength
class ViewComponents::Widgets::ExerciseTest < ActionView::TestCase
  include IconsHelper
  include Webpacker::Helper

  test "external" do
    comp = render ViewComponents::Widgets::Exercise.new(external_exercise, user_track, size: :large)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon(external_exercise)}
        #{info_div}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "external no-desc" do
    comp = render ViewComponents::Widgets::Exercise.new(external_exercise, user_track, size: :large, desc: false)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon(external_exercise)}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "external small" do
    comp = render ViewComponents::Widgets::Exercise.new(external_exercise, user_track, size: :small)
    expected = %(
      <div class="c-exercise-widget --small --locked">
        #{exercise_icon(external_exercise)}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "locked" do
    comp = render ViewComponents::Widgets::Exercise.new(locked_exercise, user_track, size: :large)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon(locked_exercise)}
        #{info_div}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "locked no-desc" do
    comp = render ViewComponents::Widgets::Exercise.new(locked_exercise, user_track, size: :large, desc: false)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon(locked_exercise)}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "locked small" do
    comp = render ViewComponents::Widgets::Exercise.new(locked_exercise, user_track, size: :small)
    expected = %(
      <div class="c-exercise-widget --small --locked">
        #{exercise_icon(locked_exercise)}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "available" do
    comp = render ViewComponents::Widgets::Exercise.new(available_exercise, user_track, size: :large)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(available_exercise)}
        #{info_div}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "available no desc" do
    comp = render ViewComponents::Widgets::Exercise.new(available_exercise, user_track, size: :large, desc: false)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(available_exercise)}
        #{info_div desc: false}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "available small" do
    comp = render ViewComponents::Widgets::Exercise.new(available_exercise, user_track, size: :small)
    expected = %(
      <a class="c-exercise-widget --small" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(available_exercise)}
        #{info_div desc: false}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "in-progress" do
    comp = render ViewComponents::Widgets::Exercise.new(in_progress_exercise, user_track, size: :large)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(in_progress_exercise)}
        #{info_div}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "in-progress no desc" do
    comp = render ViewComponents::Widgets::Exercise.new(in_progress_exercise, user_track, size: :large, desc: false)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(in_progress_exercise)}
        #{info_div desc: false}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "in-progress small" do
    comp = render ViewComponents::Widgets::Exercise.new(in_progress_exercise, user_track, size: :small)
    expected = %(
      <a class="c-exercise-widget --small" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(in_progress_exercise)}
        #{info_div desc: false}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "completed" do
    comp = render ViewComponents::Widgets::Exercise.new(completed_exercise, user_track, size: :large)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(completed_exercise)}
        #{info_div completed: true}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "completed no-desc" do
    comp = render ViewComponents::Widgets::Exercise.new(completed_exercise, user_track, size: :large, desc: false)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(completed_exercise)}
        #{info_div completed: true, desc: false}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "completed small" do
    comp = render ViewComponents::Widgets::Exercise.new(completed_exercise, user_track, size: :small)
    expected = %(
      <a class="c-exercise-widget --small" href="/tracks/ruby/exercises/bob">
        #{exercise_icon(completed_exercise)}
        #{info_div completed: true, desc: false}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  def user_track
    UserTrack.last || UserTrack::External.new(Track.last)
  end

  def external_exercise
    create :practice_exercise
  end

  def locked_exercise
    return @locked_exercise if @locked_exercise

    track = create :track
    @locked_exercise = create(:practice_exercise, track: track).tap do |exercise|
      create :exercise_prerequisite, exercise: exercise, concept: create(:track_concept, track: track)
      create :user_track, track: exercise.track
    end
  end

  def available_exercise
    create(:practice_exercise).tap do |exercise|
      create :user_track, track: exercise.track
    end
  end

  def in_progress_exercise
    create(:practice_exercise).tap do |exercise|
      user_track = create :user_track, track: exercise.track
      create :practice_solution, user: user_track.user, exercise: exercise
    end
  end

  def completed_exercise
    create(:practice_exercise).tap do |exercise|
      user_track = create :user_track, track: exercise.track
      create :practice_solution, user: user_track.user, exercise: exercise, completed_at: Time.current
    end
  end

  def lock_icon
    icon('lock', "Exercise locked", css_class: '--lock-icon')
  end

  def chevron_icon
    graphical_icon('chevron-right', css_class: '--chevron-icon')
  end

  def info_div(desc: true, completed: false)
    %(
      <div class="--info">
        <div class="--title">
          Bob
          #{%(<img role="img" alt="Exercises is completed" class="c-icon" src="#{TestHelpers.image_pack_url('completed-check-circle')}" />) if completed}
        </div>
        #{%(<div class="--desc">Atoms are internally represented</div>) if desc}
      </div>
    )
  end
end
# rubocop:enable Layout/LineLength
