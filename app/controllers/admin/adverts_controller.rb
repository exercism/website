class Admin::AdvertsController < ApplicationController
  before_action :set_partner
  before_action :set_advert, only: %i[show edit update destroy]

  # GET /admin/adverts/1
  def show; end

  # GET /admin/adverts/new
  def new
    @advert = @partner.adverts.new
  end

  # GET /admin/adverts/1/edit
  def edit; end

  # POST /admin/adverts
  def create
    @advert = @partner.adverts.new(advert_params)

    if @advert.save
      redirect_to admin_partner_advert_path(@partner, @advert), notice: "Advert was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/adverts/1
  def update
    if @advert.update(advert_params)
      redirect_to admin_partner_advert_path(@partner, @advert), notice: "Advert was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/adverts/1
  def destroy
    @advert.destroy
    redirect_to admin_partner_adverts_url(@partner), notice: "Advert was successfully destroyed."
  end

  private
  def set_partner
    @partner = Partner.find(params[:partner_id])
  end

  def set_advert
    @advert = @partner.adverts.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def advert_params
    params.require(:partner_advert).permit(*%i[status url base_text emphasised_text])
  end
end
