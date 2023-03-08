class Admin::MailshotsController < ApplicationController
  before_action :ensure_admin!
  before_action :set_mailshot, only: %i[show edit update destroy send_test send_to_audience]

  # GET /admin/mailshots
  def index
    @mailshots = Mailshot.all
    @send_counts = User::Mailshot.group(:mailshot_id).count
  end

  # GET /admin/mailshots/1
  def show
    @send_count = User::Mailshot.where(mailshot: @mailshot).count
    @audiences = [:admins]
    @audiences += Track.pluck(:slug).map { |slug| "track##{slug}" }
  end

  # GET /admin/mailshots/new
  def new
    @mailshot = Mailshot.new
    setup_form
  end

  # GET /admin/mailshots/1/edit
  def edit
    setup_form
  end

  # POST /admin/mailshots
  def create
    @mailshot = Mailshot.new(mailshot_params)

    if @mailshot.save
      redirect_to [:admin, @mailshot], notice: "mailshot was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/mailshots/1
  def update
    if @mailshot.update(mailshot_params)
      redirect_to [:admin, @mailshot], notice: "mailshot was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/mailshots/1
  def destroy
    @mailshot.destroy
    redirect_to admin_mailshots_url, notice: "mailshot was successfully destroyed."
  end

  def send_test
    Mailshot::SendTest.(@mailshot)

    flash[:mailshot_status] = "Test email sent!"

    redirect_to [:admin, @mailshot]
  end

  def send_to_audience
    audience_type, audience_slug = params[:audience].split("#")
    Mailshot::Send.(@mailshot, audience_type, audience_slug)

    flash[:mailshot_status] = "Email sent to audience: #{params[:audience]}!"

    redirect_to [:admin, @mailshot]
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_mailshot
    @mailshot = Mailshot.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def mailshot_params
    params.require(:mailshot).permit(
      :slug,
      :subject,
      :email_communication_preferences_key,
      :content_markdown,
      :text_content,
      :button_url,
      :button_text
    )
  end

  def setup_form
    @communication_preferences_keys = %i[
      email_about_events
      receive_product_updates
    ]
  end
end
