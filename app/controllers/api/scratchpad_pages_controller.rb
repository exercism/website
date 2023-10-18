class API::ScratchpadPagesController < API::BaseController
  before_action :use_page

  def show
    render json: SerializeScratchpadPage.(@page)
  end

  def update
    # TODO: (Optional) This fails if content_markdown is empty.
    # We should probably allow for that in this model
    if @page.update(scratchpad_page_params)
      render json: SerializeScratchpadPage.(@page)
    else
      render_400(:failed_validations, errors: @page.errors)
    end
  end

  private
  def use_page
    case params[:category]
    when "mentoring:exercise"
      track_slug, exercise_slug = params[:title].split(":")
      exercise = Exercise.
        joins(:track).
        where(tracks: { slug: track_slug }).
        find_by(slug: exercise_slug)

      return render_404(:scratchpad_page_not_found) unless exercise

      @page = current_user.scratchpad_pages.find_or_initialize_by(about: exercise)
    else
      render_404(:scratchpad_page_not_found)
    end
  end

  def scratchpad_page_params
    params.require(:scratchpad_page).permit(:content_markdown)
  end
end
