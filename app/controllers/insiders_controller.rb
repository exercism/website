class InsidersController < ApplicationController
  skip_before_action :authenticate_user!, except: %i[join]
  before_action :cache_public_action!, only: %i[show]

  def show
    return external unless current_user&.insider?

    @videos = VIDEOS
  end

  # Just the form, for somewhere that wants to send a user off to join and
  # have them come straight back: the editor's assistant upsell, which cannot
  # render Stripe inline on a cross-origin isolated page. `return_to` is where
  # they go afterwards, and only ever a path on this site.
  def join
    @return_to = safe_return_to
    @trigger = params[:trigger].to_s.presence_in(Analytics::TRIGGERS) || "insiders_join_page"
    redirect_to(@return_to || insiders_path) if current_user.insider?
  end

  def paypal_pending; end

  def paypal_cancelled; end

  def payment_pending
    @return_to = safe_return_to
  end

  def external
    User::InsidersStatus::TriggerUpdate.(current_user) if user_signed_in? && current_user.insiders_status_unset?

    return unless stale?(etag: VIDEOS.last)

    @features = FEATURES
    @videos = VIDEOS

    render action: :external
  end

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

  # The titles and descriptions live in config/locales/views/insiders/external.yml
  # under insiders.external.features.<key>.
  FEATURES = [
    { key: :dark_mode, icon: 'moon', filter: true },
    { key: :favorites, icon: 'feature-favorites', filter: true },
    { key: :ad_free, icon: 'feature-ad-free', filter: true },
    { key: :github_sync, icon: 'feature-github-sync', filter: true },
    { key: :name_tag_flair, icon: 'insiders' },
    { key: :behind_the_scenes, icon: 'feature-youtube', filter: true },
    { key: :private_discord, icon: 'feature-discord', filter: true },
    { key: :ai_assistant, icon: 'robot', filter: true },
    { key: :extra_mentoring_slots, icon: 'mentoring', filter: true },
    { key: :exclusive_badges, icon: 'badges', filter: true },
    { key: :exclusive_perks, icon: 'perks', filter: true },
    { key: :keep_exercism_alive, icon: 'logo', filter: true }
  ].freeze

  private
  # url_from rejects anything that isn't this host, so a value pasted in
  # from elsewhere cannot turn this into an open redirect.
  def safe_return_to = url_from(params[:return_to])
end
