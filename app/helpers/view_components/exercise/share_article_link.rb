class ViewComponents::Exercise::ShareArticleLink < ViewComponents::ViewComponent
  initialize_with :article

  def to_s = ReactComponents::Common::ShareLink.new(link).to_s
  def link = SerializeExerciseArticleForSharing.(article)
end
