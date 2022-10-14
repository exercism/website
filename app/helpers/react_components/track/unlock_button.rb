module ReactComponents
  module Track
    class UnlockButton < ReactComponent
      initialize_with :unlock_url
      def to_s
        super("track-tooltip-unlock-button", { unlock_url: })
      end
    end
  end
end
