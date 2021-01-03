module API
  class ScratchpadPagesController < BaseController
    def update
      page = current_user.scratchpad_pages.find_by(uuid: params[:id])

      return render_404 unless page

      page.update(scratchpad_page_params)

      render json: SerializeScratchpadPage.(page)
    end

    def scratchpad_page_params
      params.require(:scratchpad_page).permit(:content_markdown)
    end
  end
end
