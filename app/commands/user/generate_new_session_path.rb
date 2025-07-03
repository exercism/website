class User::GenerateNewSessionPath
  include Mandate

  initialize_with :request, :controller

  def call
    storable? ?
      Exercism::Routes.new_user_session_path(auth_return_to: request.fullpath) :
      Exercism::Routes.new_user_session_path
  end

  private
  def storable?
    return false unless request.get?
    return false if request.xhr?
    return false unless Devise.navigational_formats.include?(request.format.symbol)
    return false if controller.is_a?(::DeviseController)

    return false if request.fullpath == '/site.webmanifest'
    return false if request.fullpath.starts_with?('/courses/stripe')

    true
  end
end
