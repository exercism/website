class About::PartnersController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @partners = Partner.where.not(support_markdown: '')
  end

  def show
    @org = Partner.select(:name, :slug, :description_markdown).find_by!(slug: params[:id])
  end
end
