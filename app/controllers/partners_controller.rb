class PartnersController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @partner = Partner.find_by!(slug: params[:id])
    @perk = @partner.perks.active.first
  end

  def gobridge
    @track = Track.find('go')
    @num_concepts = @track.concepts.count
    @num_exercises = @track.exercises.count
    @num_tasks = @track.tasks.count
  end

  def code_capsules_advert_redirect
    url = user_signed_in? ?
      "https://exercism.org/perks/6471b0d6b42441bfa88fdc49e16e3425" :
      "https://codecapsules.io"
    redirect_to url, allow_other_host: true
  end
end
