module ReactComponents
  module Insiders
    class Status < ReactComponent
      def to_s
        super(
          "insiders-status",
          {
            status: 'unset'
          }
        )
      end
    end
  end
end
