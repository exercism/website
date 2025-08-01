class InsidersController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :cache_public_action!, only: %i[show]

  def show
    return external unless current_user&.insider?

    @videos = VIDEOS
  end

  def external
    User::InsidersStatus::TriggerUpdate.(current_user) if user_signed_in? && current_user.insiders_status_unset?

    return unless stale?(etag: VIDEOS.last)

    @features = FEATURES
    @videos = VIDEOS

    render action: :external
  end

  def paypal_pending; end

  def paypal_cancelled; end

  VIDEOS = [
    [:vimeo, "1050039855?h=02119c5213", "insiders-15.jpg"],
    [:vimeo, "1032194219?h=50693f7d99", "insiders-14.jpg"],
    [:vimeo, "1027581747?h=5a2ccb608c", "insiders-13.jpg"],
    [:vimeo, "1024765646?h=772526ae1d", "insiders-12.jpg"],
    [:vimeo, "904597260?h=0322718fa5", "insiders-11.jpg"],
    [:vimeo, "879746346?h=06399e1893", "insiders-10.jpg"],
    [:vimeo, "868410302?h=056539cf66", "insiders-9.jpg"],
    [:vimeo, "865572872?h=aab9cef911", "insiders-8.jpg"],
    [:vimeo, "855963806?h=7d8d19ca9e", "insiders-7.jpg"],
    [:youtube, "XjypvEa6kgM", "insiders-trophies.jpg"],
    [:vimeo, "853494393?h=3f8e06d609", "insiders-6.jpg"],
    [:vimeo, "853051394?h=c9bde0cbd4", "insiders-5.jpg"],
    [:youtube, "nroPGD11hkw", "insiders-tooling.jpg"],
    [:youtube, "GOPmj_AMbP8", "insiders-4.jpg"],
    [:youtube, "7xSHBBDzJzQ", "insiders-3.jpg"],
    [:youtube, "qOijcXroPQU", "insiders-2.jpg"],
    [:youtube, "WDUqfCMbh_8", "insiders-1.jpg"]
  ].freeze

  # rubocop:disable Layout/LineLength
  FEATURES = [
    { icon: 'moon', title: 'Dark Mode',
      desc: "Our most requested feature is available exclusive for Insiders. Our slick dark theme elevates the Exercism experience and gives your eyes an easier time while coding into the night.", filter: true },
    { icon: 'feature-favorites', title: 'Favorites',
      desc: "See a solution that inspires or intrigues you? Save it to your Favorites and then go back and learn from it later! Insiders unlocks unlimited favorites and filtering options.", filter: true },
    { icon: 'feature-ad-free', title: 'Ad-Free Experience',
      desc: "Don't like adverts? Prefer an even calmer educational environment? Insiders can turn off all adverts across the platform for a totally uninterupted learning experience!", filter: true },
    { icon: 'feature-github-sync', title: 'GitHub Sync Options',
      desc: "Want to skip pull requests? Want to change commit messages? Want to configure your own file paths? Insiders unlocks advanced customization options for GitHub Sync. Make it right for you!", filter: true },
    { icon: 'insiders', title: 'Name tag flair',
      desc: "Show off your Insiders status with our Insiders logo next to your name around the site, on Discord and our forums. Let everyone know you're supporting us!" },
    { icon: 'feature-youtube', title: 'Behind-the-scenes content',
      desc: "Keep up to date with what we're planning and building with private Insiders livestreams (rewatchable on demand) and technical deep-dives into Exercism's stack. See below for more!", filter: true },
    { icon: 'feature-discord', title: 'Private Discord channel',
      desc: "Hang out with our staff and other Insiders in our private Discord channel. Get the inside scoop on what we\'re working on and bounce ideas in realtime with us.", filter: true },
    { icon: 'robot', title: 'ChatGPT Help Integration',
      desc: "Our ChatGPT integration will help you get unstuck directly in our online editor. It's often brilliant (especially v4!), sometimes totally wrong, but always fun to experiment with!", filter: true },
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
