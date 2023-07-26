module BodyClassConcern
  extend ActiveSupport::Concern
  extend Mandate::Memoize

  memoize
  def body_class
    classes = []
    classes << "devise" if devise_controller?
    classes << "namespace-#{namespace_name}"
    classes << "controller-#{controller_name || 'none'}"
    classes << "action-#{action_name}"
    classes << theme
    classes << (user_signed_in? ? "user-signed_in" : "user-signed_out")
    classes.compact.join(" ")
  end

  memoize
  def namespace_name
    controller_parts = self.class.name.underscore.split("/")
    controller_parts.size > 1 ? controller_parts[0] : nil
  end

  def landing_page?
    namespace_name.nil? && controller_name == "pages" && action_name == "index"
  end

  def theme
    "theme-#{current_user&.preferences&.theme || 'light'}"
  end

  included do
    helper_method :body_class
    helper_method :namespace_name
    helper_method :landing_page?
  end
end
