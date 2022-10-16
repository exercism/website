class DiscourseController < ApplicationController
  def sso
    secret = "MY_SECRET_STRING"
    sso = DiscourseApi::SingleSignOn.parse(request.query_string, secret)
    sso.email = current_user.email
    sso.name = current_user.name
    sso.username = current_user.handle
    sso.external_id = current_user.id
    sso.avatar_url = current_user.avatar_url if current_user.has_avatar_url?
    sso.bio = current_user.bio
    sso.sso_secret = secret

    redirect_to sso.to_url("https://forum.exercism.org/session/sso_login"), allow_other_host: true
  end
end
