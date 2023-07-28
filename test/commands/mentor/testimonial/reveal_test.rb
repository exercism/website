require 'test_helper'

class Mentor::Testimonial::RevealTest < ActiveSupport::TestCase
  test "reveals testominal" do
    testimonial = create :mentor_testimonial, :unrevealed

    # Sanity check
    refute testimonial.revealed?

    Mentor::Testimonial::Reveal.(testimonial)

    assert testimonial.revealed?
  end

  test "resets user cache" do
    mentor = create :user
    testimonial = create(:mentor_testimonial, :unrevealed, mentor:)

    assert_user_data_cache_reset(mentor, :has_unrevealed_testimonials?, false) do
      Mentor::Testimonial::Reveal.(testimonial)
    end
  end

  test "does not reset user cache if already revealed" do
    testimonial = create :mentor_testimonial, :revealed

    User::ResetCache.expects(:defer).never

    Mentor::Testimonial::Reveal.(testimonial)
  end
end
