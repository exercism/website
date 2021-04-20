module LinksHelper
  def external_link_to(text, url, options = {})
    link_to url, options.merge(target: "_blank", rel: 'noopener') do
      (text + icon("external-link", "The link opens in a new window or tab")).html_safe
    end
  end
end
