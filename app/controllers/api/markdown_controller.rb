class API::MarkdownController < API::BaseController
  def parse
    opts = params.permit!.to_hash.with_indifferent_access[:parse_options]
    opts = opts ? opts.symbolize_keys : {}
    html = Markdown::Parse.(params[:markdown].to_s, **opts)
    render json: { html: }
  end
end
