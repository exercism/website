class User
  class Update
    include Mandate
    include Mandate::Callbacks

    initialize_with :user, :params

    def call
      ApplicationRecord.transaction do
        @user.update(user_params)
        @user.profile.update(profile_params) if has_profile?
      end

      abort!(errors) if errors.present?
    end

    memoize
    def errors
      [
        @user.errors.as_json,
        has_profile? ? @user.profile.errors.as_json : {}
      ].reject(&:empty?).flatten
    end

    private
    def has_profile?
      @user.profile
    end

    def user_params
      sanitized_params.fetch(:user, {}).slice(:name, :location, :bio, :pronoun_parts)
    end

    def profile_params
      sanitized_params.fetch(:profile, {}).slice(:github, :linkedin, :twitter)
    end

    memoize
    def sanitized_params
      params.is_a?(ActionController::Parameters) ? params.permit! : params
    end
  end
end
