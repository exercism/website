class About::SupportingOrganisationsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @supporting_orgs = SupportingOrganisation.all
  end

  def show
    @org = SupportingOrganisation.find_by!(slug: params[:id])
  end
end
