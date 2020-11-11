require "test_helper"

# rubocop:disable Layout/LineLength
class ViewComponents::Widgets::ExerciseTest < ActionView::TestCase
  test "external" do
    comp = render ViewComponents::Widgets::Exercise.new(external_exercise)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon}
        #{info_div}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "external no-desc" do
    comp = render ViewComponents::Widgets::Exercise.new(external_exercise, desc: false)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "external small" do
    comp = render ViewComponents::Widgets::Exercise.new(external_exercise, large: false)
    expected = %(
      <div class="c-exercise-widget --small --locked">
        #{exercise_icon}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "locked" do
    comp = render ViewComponents::Widgets::Exercise.new(locked_exercise)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon}
        #{info_div}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "locked no-desc" do
    comp = render ViewComponents::Widgets::Exercise.new(locked_exercise, desc: false)
    expected = %(
      <div class="c-exercise-widget --large --locked">
        #{exercise_icon}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "locked small" do
    comp = render ViewComponents::Widgets::Exercise.new(locked_exercise, large: false)
    expected = %(
      <div class="c-exercise-widget --small --locked">
        #{exercise_icon}
        #{info_div desc: false}
        #{lock_icon}
      </div>
    )
    assert_html_equal expected, comp.to_s
  end

  test "available" do
    comp = render ViewComponents::Widgets::Exercise.new(available_exercise)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "available no desc" do
    comp = render ViewComponents::Widgets::Exercise.new(available_exercise, desc: false)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div desc: false}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "available small" do
    comp = render ViewComponents::Widgets::Exercise.new(available_exercise, large: false)
    expected = %(
      <a class="c-exercise-widget --small" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div desc: false}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "in-progress" do
    comp = render ViewComponents::Widgets::Exercise.new(in_progress_exercise)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "in-progress no desc" do
    comp = render ViewComponents::Widgets::Exercise.new(in_progress_exercise, desc: false)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div desc: false}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "in-progress small" do
    comp = render ViewComponents::Widgets::Exercise.new(in_progress_exercise, large: false)
    expected = %(
      <a class="c-exercise-widget --small" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div desc: false}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "completed" do
    comp = render ViewComponents::Widgets::Exercise.new(completed_exercise)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div completed: true}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "completed no-desc" do
    comp = render ViewComponents::Widgets::Exercise.new(completed_exercise, desc: false)
    expected = %(
      <a class="c-exercise-widget --large" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div completed: true, desc: false}
        #{chevron_icon}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  test "completed small" do
    comp = render ViewComponents::Widgets::Exercise.new(completed_exercise, large: false)
    expected = %(
      <a class="c-exercise-widget --small" href="/tracks/ruby/exercises/bob">
        #{exercise_icon}
        #{info_div completed: true, desc: false}
      </a>)
    assert_html_equal expected, comp.to_s
  end

  def assert_html_equal(expected, actual)
    expected.gsub!(/^\s+/, '')
    expected.gsub!(/\s+$/, '')
    expected.delete!("\n")
    assert_equal(expected, actual)
  end

  def external_exercise
    create :practice_exercise
  end

  def locked_exercise
    create(:practice_exercise).tap do |exercise|
      create :exercise_prerequisite, exercise: exercise
      create :user_track, track: exercise.track # TODO: Will break with devise added
    end
  end

  def available_exercise
    create(:practice_exercise).tap do |exercise|
      create :user_track, track: exercise.track # TODO: Will break with devise added
    end
  end

  def in_progress_exercise
    create(:practice_exercise).tap do |exercise|
      user_track = create :user_track, track: exercise.track # TODO: Will break with devise added
      create :practice_solution, user: user_track.user, exercise: exercise
    end
  end

  def completed_exercise
    create(:practice_exercise).tap do |exercise|
      user_track = create :user_track, track: exercise.track # TODO: Will break with devise added
      create :practice_solution, user: user_track.user, exercise: exercise, completed_at: Time.current
    end
  end

  def exercise_icon
    %(<svg role="presentation" class="c-icon --exercise-icon"><use xlink:href="#sample-exercise-butterflies" /></svg>)
  end

  def lock_icon
    %(<svg role="img" class="c-icon --lock-icon"><title>Exercise locked</title><use xlink:href="#lock" /></svg>)
  end

  def chevron_icon
    %(<svg role="presentation" class="c-icon --chevron-icon"><use xlink:href="#chevron-right" /></svg>)
  end

  def info_div(desc: true, completed: false)
    %(
      <div class="--info">
        <div class="--title">
          Bob
          #{%(<svg role="img" class="c-icon "><title>Exercises is completed</title><use xlink:href="#completed-check-circle" /></svg>) if completed}
        </div>
        #{%(<div class="--desc">Atoms are internally represented</div>) if desc}
      </div>
    )
  end
end
# rubocop:enable Layout/LineLength
