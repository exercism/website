class User::Profile::InvalidateCloudfrontItem
  include Mandate

  initialize_with :user

  def call
    Infrastructure::InvalidateCloudfrontItems.defer(:website, urls)
  end

  private
  def urls
    [Exercism::Routes.profile_path(user, format: :jpg)]
  end
end
