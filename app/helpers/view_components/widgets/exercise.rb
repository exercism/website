module ViewComponents
  module Widgets
    class Exercise < ViewComponent
      extend Mandate::Memoize

      def initialize(exercise, large: true, desc: true)
        @exercise = exercise
        @large = large
        @desc = desc
      end

      def to_s
        css_class = "c-exercise-widget #{large ? '--large' : '--small'}"

        if available?
          route = Exercism::Routes.track_exercise_path(exercise.track, exercise)
          link_to(route, class: css_class) do
            parts = [ex_icon, info_tag]
            parts << graphical_icon('chevron-right', css_class: "--chevron-icon") if large
            safe_join(parts)
          end
        else
          tag.div(class: "#{css_class} --locked") do
            parts = [ex_icon + info_tag]
            parts << icon('lock', "Exercise locked", css_class: "--lock-icon")
            safe_join(parts)
          end
        end
      end

      # TODO: We want to have a solutions list that
      # pre-fetches all the relevant solutions for a
      # user, which we then pass into this. This whole
      # method should then be replaces and the solution
      # should be passed in directly.
      memoize
      def solution
        # TODO: This will break once devise is added
        Solution.for(User.first, exercise)
      end

      private
      attr_reader :exercise, :large, :desc

      def available?
        return true if solution

        # TODO: This is another example of something that should
        # be precached somewhere. What's the right way of doing this?!
        #
        # TODO: This will break once devise is added
        user_track = UserTrack.for(User.first, exercise.track)
        user_track&.exercise_available?(exercise)
      end

      def completed?
        solution&.completed?
      end

      def ex_icon
        exercise_icon(@exercise, css_class: "--exercise-icon")
      end

      def info_tag
        parts = [title_tag]
        parts << desc_tag if desc && large
        tag.div safe_join(parts), class: '--info'
      end

      def title_tag
        parts = [exercise.title]
        parts << icon("completed-check-circle", "Exercises is completed") if completed?
        tag.div safe_join(parts), class: "--title"
      end

      def desc_tag
        text = "Atoms are internally represented" # rubocop:disable Layout/LineLength
        tag.div(text, class: "--desc")
      end
    end
  end
end
