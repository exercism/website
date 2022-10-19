module ReactComponents
  module Track
    class UnlockHelpButton < ReactComponent
      initialize_with :unlock_url
      def to_s
        super("unlock-help-button", { unlock_url: })
      end
    end
  end
end
