module LinksHelper
  def external_link_to(text, url = nil, options = {})
    if block_given?
      url = text
      text = capture_haml(&block).html_safe
    end

    link_to url, options.merge(target: "_blank", rel: 'noopener') do
      (text + icon("external-link", I18n.t("helpers.links.opens_in_new_window"))).html_safe
    end
  end
end
