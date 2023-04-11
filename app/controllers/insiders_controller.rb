class InsidersController < ApplicationController
  # rubocop:disable Layout/LineLength
  FEATURES = [
    { icon: 'moon', title: 'Dark theme',
      desc: "One of our most requested features is now available for Exercism Insiders. Make Exercism even more beautiful and give your eyes a break when coding at night with our sexy new dark theme.", filter: true },
    { icon: 'robot', title: 'ChatGPT',
      desc: "Our ChatGPT integration helps you get unstuck in the editor and gives you tips when you submit. It\'s brilliant half the time and terrible the rest, but it\'s definitely fun to use!", filter: true },
    { icon: 'purple-pixel-heart', title: 'Nametag Flair & Badges',
      desc: "We\'re source great free trials and deals for you from commercial partners. It\'s their way of saying thank you for your work in Open Source." }
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

  FAQ = [
    { question: 'You wot m8?', answer: 'You dizzy blud.' },
    { question: 'You wot m8?', answer: 'You dizzy blud.' },
    { question: 'You wot m8?', answer: 'You dizzy blud.' }
  ].freeze
  # rubocop:enable Layout/LineLength

  def index
    @features = FEATURES
    @bts_access = BTS_ACCESS
    @partners = PARTNERS
    @faq = FAQ
  end
end
