module ReactComponents
  module Mentoring
    class Representation < ReactComponent
      # rubocop:disable Lint/UselessMethodDefinition
      def initialize
        # TODO: do stuff
        super
      end
      # rubocop:enable Lint/UselessMethodDefinition

      def to_s
        super("mentoring-representation", {})
      end
    end
  end
end
