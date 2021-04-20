module LayoutHelper
  def body_class
    classes = []
    classes << "devise" if devise_controller?
    classes << "namespace-#{namespace_name}"
    classes << "controller-#{controller_name || 'none'}"
    classes << "action-#{action_name}"
    classes << "theme-light"
    user_signed_in? ? classes << "user-signed_in" : classes << "user-signed_out"
    classes.join(" ")
  end
end
