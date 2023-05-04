require 'test_helper'

class Mentor::Testimonial::CreateTest < ActiveSupport::TestCase
  test "creates testimonial" do
    discussion = create :mentor_discussion
    content = "Such a lovely chat"

    Mentor::Testimonial::Create.(discussion, content)

    assert_equal 1, Mentor::Testimonial.count

    testimonial = Mentor::Testimonial.last
    assert_equal discussion, testimonial.discussion
    assert_equal discussion.mentor, testimonial.mentor
    assert_equal discussion.student, testimonial.student
    assert_equal content, testimonial.content
  end

  test "resets cache" do
    discussion = create :mentor_discussion
    content = "Such a lovely chat"

    User::ResetCache.(discussion.mentor)

    Mentor::Testimonial::Create.(discussion, content)
  end
end
