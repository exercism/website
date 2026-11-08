module ViewComponents
  # Asks people who signed up before the sign-up page asked their level where
  # they are in their coding journey. It replaces the five-level seniority
  # survey, and shows until they answer.
  class ReturningUserModal < ViewComponent
    # BegModal reads this to avoid showing straight after this modal.
    SHOWN_AT_FLAG = "shown_seniority_modal_at".freeze

    def to_s
      return unless user_signed_in?
      return if showing_modal?
      return if current_user.seniority
      return unless ::User::DetermineIfOnboardingAsksSeniority.(current_user)

      showing_modal!
      session[SHOWN_AT_FLAG] = Time.current

      render("components/returning_user_modal", tracks: ::Track::RetrieveSignUpCodeCheckTracks.())
    end
  end
end
