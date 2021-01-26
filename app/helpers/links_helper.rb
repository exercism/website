module LinksHelper
  def external_link_to(text, url)
    link_to url, target: "_blank", rel: 'noopener' do
      (text + icon("external-link", "The link opens in a new window or tab")).html_safe
    end
  end
end
