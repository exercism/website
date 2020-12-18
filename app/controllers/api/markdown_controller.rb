module API
  class MarkdownController < BaseController
    def parse
      html = ParseMarkdown.(params[:markdown].to_s)

      render json: { html: html }
    end
  end
end
