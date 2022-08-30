module ReactComponents
  class ReactComponent < ViewComponents::ViewComponent
    include ActionView::Helpers::TagHelper

    def to_s(id, data, fitted: false, wrapper_class_modifier: nil, style: nil, content: nil)
      css_classes = ["c-react-component"]
      css_classes << "c-react-wrapper-#{id}"
      css_classes << "c-react-wrapper-#{id}-#{wrapper_class_modifier}" if wrapper_class_modifier.present?
      css_classes << '--fitted' if fitted
      tag.div(
        content.presence,
        class: css_classes.join(" "),
        style:,
        "data-react-id": id,
        "data-react-data": data.to_json,
        "data-react-hydrate": content.present?
      )
    end
  end
end
