class InsidersController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    return external unless current_user&.insider?
  end

  def external
    User::InsidersStatus::TriggerUpdate.(current_user) if user_signed_in? && current_user.insiders_status_unset?

    @features = FEATURES

    render action: :external
  end

  # rubocop:disable Layout/LineLength
  FEATURES = [
    { icon: 'premium', title: 'Premium for free',
      desc: "Get Exercism Premium for free. All the features, badges and extra goodies that come with Premium are yours to enjoy for free.", filter: false },
    { icon: 'feature-youtube', title: 'Exclusive content',
      desc: "Keep up to date with what we're planning and building with private Insiders livestreams (rewatchable on demand) and technical deep-dives into Exercism's stack.", filter: true },
    { icon: 'feature-discord', title: 'Private Discord channel',
      desc: "Hang out with our staff and other Insiders in our private Discord channel. Get inside-access on what we\'re working on and bounce ideas in realtime with us.", filter: true }
  ].freeze
  # rubocop:enable Layout/LineLength
end
