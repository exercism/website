module ReactComponents
  module Track
    class UnlockButton < ReactComponent
      # initialize_with unlock_url:unlock_help_api_solution_url(@solution.uuid)
      initialize_with unlock_url: "https://exercism.org"
      def to_s
        super("track-tooltip-unlock-button", {
          unlock_url:
        })
      end
    end
  end
end
