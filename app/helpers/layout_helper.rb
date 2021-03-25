module LayoutHelper
  def body_class
    classes = []
    classes << "devise" if devise_controller?
    classes << "namespace-#{namespace_name}"
    classes << "controller-#{controller_name}"
    classes << "action-#{action_name}"
    classes << "theme-light"
    user_signed_in? ? classes << "user-signed_in" : classes << "user-signed_out"
    classes.join(" ")
  end

  def namespace_name
    @namespace_name ||= begin
      controller_parts = controller.class.name.underscore.split("/")
      controller_parts.size > 1 ? controller_parts[0] : 'none'
    end
  end
end
