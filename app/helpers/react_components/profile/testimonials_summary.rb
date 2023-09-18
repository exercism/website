module ReactComponents
  module Profile
    class TestimonialsSummary < ReactComponent
      def initialize(user, profile)
        @user = user
        @profile = profile

        super()
      end

      def to_s
        return nil if num_published_testimonials.zero?

        super("profile-testimonials-summary", {
          handle: user.handle,
          flair: user.flair,
          num_testimonials_received: num_published_testimonials,
          num_solutions_mentored:,
          num_students_helped: num_students_mentored,
          # TODO: (Optional) Add test for published
          testimonials: SerializeMentorTestimonials.(user.mentor_testimonials.published.limit(3)),
          links: {
            all: profile.testimonials_tab? ? Exercism::Routes.testimonials_profile_path(user) : nil
          }
        })
      end

      private
      attr_reader :user, :profile

      delegate :num_students_mentored,
        :num_solutions_mentored,
        :num_published_testimonials, to: :user
    end
  end
end
