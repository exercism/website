class PremiumController < ApplicationController
  skip_before_action :authenticate_user!
  def show
    return external unless current_user&.premium?
  end

  def external
    @features = FEATURES

    render action: :external
  end

  def paypal_status; end

  # rubocop:disable Layout/LineLength
  FEATURES = [
    { icon: 'moon', title: 'Dark Mode',
      desc: "Our most requested feature is available exclusive for Premium members. Our slick dark theme elevates the Exercism experience and gives your eyes an easier time while coding into the night.", filter: true },
    { icon: 'robot', title: 'ChatGPT',
      desc: "Our ChatGPT integration will help you get unstuck directly in our online editor. It's often brilliant (especially v4!), sometimes totally wrong, but always fun to experiment with!", filter: true },
    { icon: 'premium', title: 'Name tag flair',
      desc: "Show off your Premium status with our Premium logo next to your name around the site, on Discord and our forums. Let everyone know you're supporting us!" },
    { icon: 'mentoring', title: 'Extra Mentoring Slots',
      desc: "Unlock more simultaneous mentoring slots per track without needing to earn reputation, and improve the speed at which you can work through a track with our mentors' support.", filter: true },
    { icon: 'badges', title: 'Exclusive Badges',
      desc: "Immediately recieve the rare Premium Member badge for your profile. Then unlock extra exclusive badges as you use Exercism - only available to Premium members.", filter: true },
    { icon: 'perks', title: 'Exclusive Perks',
      desc: "Receive exclusive discounts and offers from our partners as part of Exercism Perks. Get cheaper products, services, books and more, all through Premium. (Perks launching soon)", filter: true }
  ].freeze
  # rubocop:enable Layout/LineLength
end
