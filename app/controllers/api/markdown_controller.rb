module API
  class MarkdownController < BaseController
    def parse
      html = Markdown::Parse.(params[:markdown].to_s)

      render json: { html: html }
    end
  end
end
