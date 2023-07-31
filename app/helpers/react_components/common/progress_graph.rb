module ReactComponents
  module Common
    class ProgressGraph < ReactComponent
      initialize_with :data, :height, :width

      def to_s
        super(
          "common-progress-graph", {
            values: data,
            height:,
            width:
          }
        )
      end

      private
      attr_reader :data, :height, :width
    end
  end
end
