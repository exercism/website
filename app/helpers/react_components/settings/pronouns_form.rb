module ReactComponents
  module Settings
    class PronounsForm < ReactComponent
      def to_s
        super("settings-pronouns-form", {
          handle: current_user.handle,
          pronoun_parts: current_user.pronoun_parts,
          links: {
            update: Exercism::Routes.api_settings_url,
            info: "#"
          }
        })
      end
    end
  end
end
