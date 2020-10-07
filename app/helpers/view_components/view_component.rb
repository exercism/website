module ViewComponents
  class ViewComponent
    include ActionView::Helpers::TagHelper
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    def react_component(id, data)
      tag :div, {
        "data-react-#{id}": true,
        "data-react-data": data.to_json
      }
    end
  end
end
