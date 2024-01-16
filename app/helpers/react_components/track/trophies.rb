module ReactComponents
  module Track
    class Trophies < ReactComponent
      initialize_with :track, :user

      def to_s
        super("track-trophies", { trophies: })
      end

      private
      def trophies = SerializeTrackTrophies.(track, user)
    end
  end
end
