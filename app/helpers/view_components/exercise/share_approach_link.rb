class ViewComponents::Exercise::ShareApproachLink < ViewComponents::ViewComponent
  initialize_with :approach

  def to_s = ReactComponents::Common::ShareLink.new(link).to_s
  def link = SerializeExerciseApproachForSharing.(approach)
end
