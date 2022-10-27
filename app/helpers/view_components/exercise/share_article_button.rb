class ViewComponents::Exercise::ShareArticleButton < ViewComponents::ViewComponent
  initialize_with :article

  def to_s = ReactComponents::Common::ShareButton.new(link).to_s
  def link = SerializeExerciseArticleForSharing.(article)
end
