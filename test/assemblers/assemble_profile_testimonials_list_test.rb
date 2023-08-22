require "test_helper"

class AssembleProfileTestimonialsListTest < ActiveSupport::TestCase
  test "should return top 20 serialized correctly" do
    mentor = create :user
    5.times do
      create(:mentor_testimonial, :revealed, mentor:)
    end

    paginated_testimonials = mentor.mentor_testimonials.order(id: :desc).page(1).per(64)
    expected = SerializePaginatedCollection.(
      paginated_testimonials,
      serializer: SerializeMentorTestimonials,
      meta: { unscoped_total: 5 }
    )

    assert_equal expected, AssembleProfileTestimonialsList.(mentor, {})
  end
end
