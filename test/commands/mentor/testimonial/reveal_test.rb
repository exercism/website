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
    testimonial = create :mentor_testimonial, :unrevealed

    User::ResetCache.expects(:call).with(testimonial.mentor)

    Mentor::Testimonial::Reveal.(testimonial)
  end
end
