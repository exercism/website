class Admin::PartnersController < Admin::BaseController
  before_action :set_partner, only: %i[show edit update destroy]

  # GET /admin/partners
  def index
    @partners = Partner.order(name: :asc)
  end

  # GET /admin/partners/1
  def show; end

  # GET /admin/partners/new
  def new
    @partner = Partner.new
  end

  # GET /admin/partners/1/edit
  def edit; end

  # POST /admin/partners
  def create
    @partner = Partner.new(partner_params)

    if @partner.save
      redirect_to [:admin, @partner], notice: "Community video was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/partners/1
  def update
    if @partner.update(partner_params)
      redirect_to [:admin, @partner], notice: "Community video was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/partners/1
  def destroy
    @partner.destroy
    redirect_to partners_url, notice: "Community video was successfully destroyed."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_partner
    @partner = Partner.find_by(slug: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def partner_params
    params.require(:partner).permit(
      :name, :slug, :website_url, :headline, :description_markdown, :support_markdown,
      :light_logo, :dark_logo
    )
  end
end
