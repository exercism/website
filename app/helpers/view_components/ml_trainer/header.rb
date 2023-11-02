module ViewComponents
  module MLTrainer
    class Header < ViewComponent
      def to_s
        tag.nav(class: 'c-mentor-header') do
          tag.div(class: 'lg-container container') do
            top
          end
        end
      end

      def top
        tag.nav(class: "top") do
          tag.div(class: "title") do
            graphical_icon(:mentoring, hex: true) +
              tag.span("ML Trainer")
          end
        end
      end
    end
  end
end
