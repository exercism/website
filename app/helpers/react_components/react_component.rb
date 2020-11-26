module ReactComponents
  class ReactComponent
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    include ActionView::Helpers::TagHelper

    def to_s(id, data, fitted: false)
      tag.div(
        "",
        {
          class: "c-react-component #{'--fitted' if fitted}",
          "data-react-#{id}": true,
          "data-react-data": data.to_json
        }
      )
    end

    def class_name; end
  end
end
