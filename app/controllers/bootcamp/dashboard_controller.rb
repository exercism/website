class Bootcamp::DashboardController < Bootcamp::BaseController
  def index
    @exercise = Bootcamp::SelectNextExercise.(current_user)
    @solution = current_user.bootcamp_solutions.find_by(exercise: @exercise)

    bd = current_user.bootcamp_data
    ulidx = bd.active_part == 1 ? bd.part_1_level_idx : bd.part_2_level_idx
    level_idx = [Bootcamp::Settings.level_idx, ulidx].min
    level_idx = bd.active_part == 1 ? 1 : 11 if level_idx.zero?
    @level = Bootcamp::Level.find_by!(idx: level_idx)
  end

  def change_part
    bd = current_user.bootcamp_data
    if bd.enrolled_in_both_parts?
      part = params[:part].to_i
      part = 1 unless [1, 2].include?(part)
      bd.update!(active_part: part)
    end

    redirect_to bootcamp_dashboard_path
  end

  def image_proxy
    require 'open-uri'

    url = "https://assets.exercism.org/images/bootcamp/#{params[:filename]}.#{params[:format]}"
    begin
      image = URI.open(url) # rubocop:disable Security/Open
      send_data image.read, type: image.content_type, disposition: 'inline'
    rescue OpenURI::HTTPError
      head :not_found
    end
  end
end
