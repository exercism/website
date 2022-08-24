module ReactComponents
  module Impact
    class Stat < ReactComponent
      initialize_with :metric, :value

      def to_s
        super(
          "impact-stat",
          {
            metric:,
            value:
          },
          content: number_with_delimiter(value)
        )
      end
    end
  end
end
