module ReactComponents
  module Common
    class SiteUpdatesList < ReactComponent
      initialize_with :updates, :context

      def to_s
        super("common-site-updates-list", {
          updates: SerializeSiteUpdates.(updates),
          context:
        })
      end
    end
  end
end
