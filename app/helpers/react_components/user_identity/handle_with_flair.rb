module ReactComponents
  module UserIdentity
    # The handle is immutable and stays server-rendered inside the component's
    # data; only the flair icon comes from the API.
    class HandleWithFlair < ReactComponent
      initialize_with :handle, size: :base, class_name: nil

      def to_s
        super(
          "user-identity-handle-with-flair",
          {
            handle:,
            size:,
            class_name:
          },
          fitted: true,
          style: "display: inline-flex; vertical-align: middle"
        )
      end
    end
  end
end
