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

  def js_packs
    packs = ['application']
    packs << 'internal' if user_signed_in?
    if (namespace_name == "tracks" && controller_name == "exercises" && action_name == "edit") ||
       (namespace_name == "test" && controller_name == "editor" && action_name == "show")
      packs << 'editor'
    end

    packs
  end
end
