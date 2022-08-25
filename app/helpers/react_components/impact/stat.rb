module ReactComponents
  module Impact
    class Stat < ReactComponent
      initialize_with :type, :value

      def to_s
        super(
          "impact-stat",
          {
            type:,
            value:
          },
          content: number_with_delimiter(value)
        )
      end
    end
  end
end
