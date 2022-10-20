class ReactComponents::Common::ShareLink < ReactComponents::ReactComponent
  initialize_with :params

  def to_s
    super("share-link", {
      title: params[:title],
      share_title: params[:share_title],
      share_link: params[:share_link],
      platforms: Exercism.share_platforms
    })
  end
end
