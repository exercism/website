require "test_helper"

class Mentor::TestimonialTest < ActiveSupport::TestCase
  test "not_deleted scope" do
    testimonial = create :mentor_testimonial, deleted_at: nil
    create :mentor_testimonial, deleted_at: Time.current

    assert_equal [testimonial], Mentor::Testimonial.not_deleted
  end

  test "soft_destroy! resets the mentor's published testimonial count" do
    testimonial = create :mentor_testimonial, :revealed

    assert_user_data_cache_reset(testimonial.mentor, :num_published_testimonials, 0) do
      testimonial.soft_destroy!
    end
  end
end
