class About::SupportingOrganisationsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @supporting_orgs = SupportingOrganisation.select(:name, :slug, :support_explanation)
  end

  def show
    @org = SupportingOrganisation.select(:name, :slug, :description_markdown).find_by!(slug: params[:id])
  end
end
