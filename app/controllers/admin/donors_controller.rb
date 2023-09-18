class Admin::DonorsController < Admin::BaseController
  # GET /admin/donors
  def index
    user_ids = User::Data.public_supporter.
      order(first_donated_at: :asc).
      page(params[:page]).per(30).without_count.
      pluck(:user_id)

    users = User.where(id: user_ids).sort_by { |u| user_ids.index(u.id) }
    @donors = Kaminari.paginate_array(users, total_count: User::Data.donors.count).
      page(params[:page]).per(30)
  end

  # GET /admin/donors/new
  def new; end

  # POST /admin/donors
  def create
    user = User.find_by(email: params[:email]&.strip)

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
      flash[:donors_notice] = "Donor was successfully created."
      redirect_to %i[admin donors]
    rescue ArgumentError
      @error = "Invalid first donated at date"
      render :new
    end
  end
end
