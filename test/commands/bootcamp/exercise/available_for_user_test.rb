require 'test_helper'

class Bootcamp::Exercise::AvailableForUserTest < ActiveSupport::TestCase
  test "return true if first exercise" do
    create :bootcamp_level, idx: 1
    exercise = create :bootcamp_exercise, level_idx: 1
    user = create :user

    Bootcamp::Settings.instance.update(level_idx: 1)

    assert Bootcamp::Exercise::AvailableForUser.(exercise, user)
  end

  test "return false if level not reached" do
    (1..2).each { |idx| create :bootcamp_level, idx: }
    exercise = create :bootcamp_exercise, level_idx: 2
    user = create :user

    Bootcamp::Settings.instance.update(level_idx: 1)

    refute Bootcamp::Exercise::AvailableForUser.(exercise, user)
  end
end
