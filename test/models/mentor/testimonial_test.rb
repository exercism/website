require "test_helper"

class Mentor::TestimonialTest < ActiveSupport::TestCase
  test "not_deleted scope" do
    testimonial = create :mentor_testimonial, deleted_at: nil
    create :mentor_testimonial, deleted_at: Time.current

    assert_equal [testimonial], Mentor::Testimonial.not_deleted
  end
end
