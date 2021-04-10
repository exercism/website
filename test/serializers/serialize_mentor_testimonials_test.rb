require 'test_helper'

class SerializeMentorTestimonialsTest < ActiveSupport::TestCase
  test "basic testimonial" do
    testimonial = create :mentor_testimonial

    expected = [
      {
        id: testimonial.uuid
      }
    ]

    assert_equal expected, SerializeMentorTestimonials.(Mentor::Testimonial.all)
  end
end
