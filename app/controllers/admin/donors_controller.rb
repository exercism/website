class Admin::DonorsController < ApplicationController
  before_action :ensure_staff!

  # GET /admin/donors
  def index
    @donors = User.donor.
      order(first_donated_at: :desc).
      page(params[:page]).
      per(30)
  end

  # GET /admin/donors/new
  def new; end

  # POST /admin/donors
  def create
    user = User.find_by(email: params[:email])

    if user.nil?
      @error = "Could not find user with this email address"
      return render :new
    end

    begin
      first_donated_at = Time.find_zone("UTC").parse(params[:first_donated_at])

      if first_donated_at > Time.current
        @error = "First donated at date must be in past"
        return render :new
      end

      User::RegisterAsDonor.(user, first_donated_at)
      redirect_to %i[admin donors], notice: "Donor was successfully created."
    rescue ArgumentError
      @error = "Invalid first donated at date"
      render :new
    end
  end
end
