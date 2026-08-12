module ReactComponents
  module UserIdentity
    # Whether a user has a profile is a user-level fact, so the link wrapper is
    # resolved client-side. The text is passed through and always rendered.
    class ProfileLink < ReactComponent
      initialize_with :handle, :text, class_name: nil

      def to_s
        super(
          "user-identity-profile-link",
          {
            handle:,
            text:,
            class_name:
          },
          fitted: true,
          style: "display: inline-flex; vertical-align: middle"
        )
      end
    end
  end
end
