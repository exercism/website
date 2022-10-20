class ViewComponents::Exercise::ShareApproachButton < ViewComponents::ViewComponent
  initialize_with :approach

  def to_s = ReactComponents::Common::ShareButton.new(link).to_s
  def link = SerializeExerciseApproachForSharing.(approach)
end
