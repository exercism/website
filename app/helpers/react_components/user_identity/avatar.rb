module ReactComponents
  module UserIdentity
    # Avatar URLs are versioned, and profile existence can change, so both are
    # fetched client-side rather than cached into the page HTML.
    class Avatar < ReactComponent
      initialize_with :handle, link: false, class_name: nil

      def to_s
        super(
          "user-identity-avatar",
          {
            handle:,
            link:,
            class_name:
          },
          fitted: true
        )
      end
    end
  end
end
