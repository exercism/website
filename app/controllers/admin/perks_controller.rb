class Admin::PerksController < ApplicationController
  before_action :set_partner
  before_action :set_perk, only: %i[show edit update destroy]

  # GET /admin/perks/1
  def show; end

  # GET /admin/perks/new
  def new
    @perk = @partner.perks.new
  end

  # GET /admin/perks/1/edit
  def edit; end

  # POST /admin/perks
  def create
    @perk = @partner.perks.new(perk_params)

    if @perk.save
      redirect_to admin_partner_perk_path(@partner, @perk), notice: "Perk was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/perks/1
  def update
    if @perk.update(perk_params)
      redirect_to admin_partner_perk_path(@partner, @perk), notice: "Perk was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/perks/1
  def destroy
    @perk.destroy
    redirect_to admin_partner_perks_url(@partner), notice: "Perk was successfully destroyed."
  end

  private
  def set_partner
    @partner = Partner.find_by(slug: params[:partner_id])
  end

  def set_perk
    @perk = @partner.perks.find_by(uuid: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def perk_params
    params.require(:partner_perk).permit(
      *%i[
        status preview_text
        light_logo dark_logo
        general_url general_offer_summary_markdown general_button_text general_offer_details general_voucher_code
        premium_url premium_offer_summary_markdown premium_button_text premium_offer_details premium_voucher_code

      ]
    )
  end
end
