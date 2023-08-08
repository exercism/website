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

  def paypal_pending; end

  def paypal_cancelled; end

  # rubocop:disable Layout/LineLength
  FEATURES = [
    { icon: 'feature-youtube', title: 'Behind-the-scenes content',
      desc: "Keep up to date with what we're planning and building with private Insiders livestreams (rewatchable on demand) and technical deep-dives into Exercism's stack.", filter: true },
    { icon: 'moon', title: 'Dark Mode',
      desc: "Our most requested feature is available exclusive for Insiders. Our slick dark theme elevates the Exercism experience and gives your eyes an easier time while coding into the night.", filter: true },
    { icon: 'feature-discord', title: 'Private Discord channel',
      desc: "Hang out with our staff and other Insiders in our private Discord channel. Get the inside scoop on what we\'re working on and bounce ideas in realtime with us.", filter: true },
    { icon: 'robot', title: 'ChatGPT Help Integration',
      desc: "Our ChatGPT integration will help you get unstuck directly in our online editor. It's often brilliant (especially v4!), sometimes totally wrong, but always fun to experiment with!", filter: true },
    { icon: 'insiders', title: 'Name tag flair',
      desc: "Show off your Insiders status with our Insiders logo next to your name around the site, on Discord and our forums. Let everyone know you're supporting us!" },
    { icon: 'mentoring', title: 'Extra Mentoring Slots',
      desc: "Unlock more simultaneous mentoring slots per track without needing to earn reputation, and improve the speed at which you can work through a track with our mentors' support.", filter: true },
    { icon: 'badges', title: 'Exclusive Badges',
      desc: "Immediately recieve the rare Insiders badge for your profile. Then unlock extra exclusive badges as you use Exercism - only available to Insiders.", filter: true },
    { icon: 'perks', title: 'Exclusive Perks',
      desc: "Receive exclusive discounts and offers from our partners as part of Exercism Perks. Get cheaper products, services, books and more, all through Insiders.", filter: true },
    { icon: 'logo', title: 'Keep Exercism alive',
      desc: "Last but not least, you help keep Exercism alive! Without your support, we can't pay for our servers or our staff. Thank you for giving back and supporting free education 💙", filter: true }

  ].freeze
  # rubocop:enable Layout/LineLength
end
