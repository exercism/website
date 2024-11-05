module ReactComponents
  module Common
    class TrackSlugsMultiselector < ReactComponent
      initialize_with :track_slugs

      def to_s
        super("common-track-slugs-multiselector", { track_slugs: })
      end
    end
  end
end
