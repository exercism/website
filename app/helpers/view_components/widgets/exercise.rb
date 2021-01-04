module ViewComponents
  module Widgets
    class Exercise < ViewComponent
      extend Mandate::Memoize
      SIZES = %i[small medium large].freeze

      def initialize(exercise, user_track, size:, desc: true)
        raise "Invalid exercise size #{size}" unless SIZES.include?(size.to_sym)

        super()

        @exercise = exercise
        @user_track = user_track
        @size = size
        @desc = desc
      end

      def to_s
        css_class = "c-exercise-widget --#{size}"

        if available?
          route = Exercism::Routes.track_exercise_path(exercise.track, exercise)
          link_to(route, class: css_class) do
            parts = [ex_icon, info_tag]
            parts << graphical_icon('chevron-right', css_class: "--chevron-icon") unless small?
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

      private
      attr_reader :exercise, :user_track, :size, :desc

      def available?
        user_track.exercise_available?(exercise)
      end

      def completed?
        user_track.exercise_completed?(exercise)
      end

      def ex_icon
        exercise_icon(@exercise, css_class: "--exercise-icon")
      end

      def info_tag
        parts = [title_tag]
        parts << desc_tag if desc && !small?
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

      def small?
        size == :small
      end

      def large?
        size == :large
      end
    end
  end
end
