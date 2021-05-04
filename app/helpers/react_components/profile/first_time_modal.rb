module ReactComponents
  module Profile
    class FirstTimeModal < ReactComponent
      initialize_with :profile

      def to_s
        super("profile-first-time-modal", {
          links: {
            profile: Exercism::Routes.profile_url(profile)
          }
        })
      end
    end
  end
end
