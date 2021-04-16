module ReactComponents
  module Profile
    class TestimonialsSummary < ReactComponent
      def initialize(user, profile)
        @user = user
        @profile = profile

        super()
      end

      def to_s
        return nil if num_testimonials.zero?

        super("profile-testimonials-summary", {
          handle: user.handle,
          num_testimonials: num_testimonials,
          num_solutions_mentored: 572,
          num_students_helped: 390,
          num_testimonials_received: 55,
          testimonials: SerializeMentorTestimonials.(user.mentor_testimonials.limit(3)),
          links: {
            all: profile.testimonials_tab? ? "#" : nil
          }
        })
      end

      private
      attr_reader :user, :profile

      memoize
      def num_testimonials
        user.mentor_testimonials.count
      end
    end
  end
end
