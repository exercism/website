module Mentor
  class Testimonial
    class Retrieve
      include Mandate

      # Use class method rather than constant for
      # easier stubbing during testing
      def self.testimonials_per_page
        10
      end

      def initialize(mentor:,
                     page: 1,
                     criteria: nil, order: nil,
                     track_slug: nil,
                     include_unrevealed: false)
        @mentor = mentor
        @page = page.to_i
        @criteria = criteria
        @order = order || :newest
        @track_slug = track_slug
        @include_unrevealed = include_unrevealed
      end

      def call
        setup!
        filter!
        search!
        sort!
        paginate!

        @testimonials
      end

      private
      attr_reader :mentor, :page, :criteria, :order, :track_slug, :include_unrevealed

      def setup!
        @testimonials = mentor.mentor_testimonials
      end

      def filter!
        @testimonials = @testimonials.where(revealed: true) unless include_unrevealed

        filter_track!
      end

      def filter_track!
        return if track_slug.blank?

        @testimonials = @testimonials.
          joins(solution: :track).
          where('tracks.slug': track_slug)
      end

      def search!
        return if criteria.blank?

        # TODO: This is just a stub implementation
        @testimonials = @testimonials.joins(:student).where("users.handle LIKE ?", "%#{criteria}%")
      end

      def sort!
        case order
        when :newest
          @testimonials = @testimonials.order("mentor_testimonials.created_at DESC")
        when :oldest
          @testimonials = @testimonials.order("mentor_testimonials.created_at ASC")
        end
      end

      def paginate!
        @testimonials = @testimonials.
          page(page).per(self.class.testimonials_per_page)
      end
    end
  end
end
