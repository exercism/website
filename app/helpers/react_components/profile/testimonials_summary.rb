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
          flair: user.flair,
          num_testimonials:,
          num_solutions_mentored:,
          num_students_helped:,
          num_testimonials_received: num_testimonials,
          # TODO: (Optional) Add test for published
          testimonials: SerializeMentorTestimonials.(user.mentor_testimonials.published.limit(3)),
          links: {
            all: profile.testimonials_tab? ? Exercism::Routes.testimonials_profile_path(user) : nil
          }
        })
      end

      private
      attr_reader :user, :profile

      memoize
      def num_testimonials
        user.mentor_testimonials.published.count
      end

      def num_solutions_mentored
        @user.mentor_discussions.count
      end

      def num_students_helped
        @user.mentor_discussions.joins(:solution).distinct.count(:user_id)
      end
    end
  end
end
