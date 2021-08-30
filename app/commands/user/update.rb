class User
  class Update
    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      ApplicationRecord.transaction do
        @user.update(user_params)
        @user.profile.update(profile_params) if has_profile?
      end

      errors.blank?
    end

    def errors
      [
        @user.errors.as_json,
        has_profile? ? @user.profile.errors.as_json : {}
      ].reject(&:empty?).flatten
    end

    private
    attr_reader :user, :params

    def has_profile?
      @user.profile.present?
    end

    def user_params
      params.require(:user).permit(
        :name, :location, :bio,
        pronoun_parts: []
      )
    end

    def profile_params
      params.require(:profile).permit(:github, :linkedin, :twitter)
    end
  end
end
