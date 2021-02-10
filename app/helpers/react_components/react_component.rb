module ReactComponents
  class ReactComponent < ViewComponents::ViewComponent
    include ActionView::Helpers::TagHelper

    def to_s(id, data, fitted: false, wrapper_class_modifier: "")
      css_classes = ["c-react-component"]
      css_classes << "c-react-wrapper-#{id}"
      css_classes << "c-react-wrapper-#{id}-#{wrapper_class_modifier}" if wrapper_class_modifier.present?
      css_classes << '--fitted' if fitted
      tag.div(
        "",
        {
          class: css_classes.join(" "),
          "data-react-#{id}": true,
          "data-react-data": data.to_json
        }
      )
    end
  end
end
