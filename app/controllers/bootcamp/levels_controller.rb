class Bootcamp::LevelsController < Bootcamp::BaseController
  def index
    @levels = Bootcamp::Level.all.index_by(&:idx)
  end

  def show
    @level = Bootcamp::Level.find_by!(idx: params[:idx])
  end
end
