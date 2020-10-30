module ViewComponents
  class ViewComponent
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include IconsHelper

    # TODO: This can probably be removed
    include ActionView::Helpers::AssetTagHelper

    include ActionView::Context

    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    def react_component(id, data)
      tag.div("", {
                "data-react-#{id}": true,
                "data-react-data": data.to_json
              })
    end
  end
end
