class PremiumController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    return external unless current_user&.premium?
  end

  def external
    @features = FEATURES
    @bts_access = BTS_ACCESS
    @partners = PARTNERS

    render action: :external
  end

  # rubocop:disable Layout/LineLength
  FEATURES = [
    { icon: 'moon', title: 'Dark theme',
      desc: "Our most requested feature will be available for Insiders at launch. Our slick new dark theme will make Exercism even more beautiful and will give your eyes a break while coding at night.", filter: true },
    { icon: 'robot', title: 'ChatGPT',
      desc: "Our ChatGPT integration will help you get unstuck in the editor and give you tips when you submit a solution. It\'s brilliant half the time and terrible the rest, but it\'s definitely fun to use!", filter: true },
    { icon: 'insiders', title: 'Name tag flair & Badges',
      desc: "Celebrate your Insiders status with our Insiders logo next to your name around the site, on Discord and our forums. Plus get an exclusive Lifetime Insider badge." }
  ].freeze

  BTS_ACCESS = [
    { icon: 'feature-youtube', title: 'Exclusive content',
      desc: "Keep up to date with what we're planning and building with private Insiders livestreams (rewatchable on demand) and technical deep-dives into Exercism's stack.", filter: true },
    { icon: 'feature-discord', title: 'Private Discord channel',
      desc: "Hang out with our staff and other Insiders in our private Discord channel. Get inside-access on what we\'re working on and bounce ideas in realtime with us.", filter: true },
    { icon: 'megaphone', title: 'Contribute on community calls',
      desc: "Our community calls are watchable by anyone, but only Insiders join in the conversation. Come and chat with the team and give us your thoughts and ideas.", filter: true }
  ].freeze

  PARTNERS = [
    { icon: 'figma', name: 'Figma', offer: 'Get 20% off your monthly subscription!' },
    { icon: 'figma', name: 'Figma', offer: 'Get 20% off your monthly subscription!' },
    { icon: 'figma', name: 'Figma', offer: 'Get 20% off your monthly subscription!' },
    { icon: 'figma', name: 'Figma', offer: 'Get 20% off your monthly subscription!' }
  ].freeze

  # rubocop:enable Layout/LineLength
end
