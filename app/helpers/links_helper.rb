module LinksHelper
  def external_link_to(text, url = nil, options = {})
    if block_given?
      url = text
      text = capture_haml(&block).html_safe
    end

    link_to url, options.merge(target: "_blank", rel: 'noopener') do
      (text + icon("external-link", "The link opens in a new window or tab")).html_safe
    end
  end
end
