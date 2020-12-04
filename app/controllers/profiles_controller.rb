class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:tooltip]

  def tooltip
    expires_in 1.minute

    @user = User.find_by(handle: params[:id])

    # TODO: This should be a real model
    @profile = OpenStruct.new(
      name: "Erik ShireBOOM",
      bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",  # rubocop:disable Layout/LineLength
      location: "Bree, Middle Earth."
    )
    render layout: false
  end
end
