class Admin::StreamingEventsController < Admin::BaseController
  before_action :ensure_admin!
  before_action :set_streaming_event, only: %i[show edit update destroy]

  # GET /admin/streaming_events
  def index
    @streaming_events = StreamingEvent.all
  end

  # GET /admin/streaming_events/1
  def show; end

  # GET /admin/streaming_events/new
  def new
    @streaming_event = StreamingEvent.new
  end

  # GET /admin/streaming_events/1/edit
  def edit; end

  # POST /admin/streaming_events
  def create
    @streaming_event = StreamingEvent.new(streaming_event_params)

    if @streaming_event.save
      redirect_to [:admin, @streaming_event], notice: "Streaming event was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/streaming_events/1
  def update
    if @streaming_event.update(streaming_event_params)
      redirect_to [:admin, @streaming_event], notice: "Streaming event was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/streaming_events/1
  def destroy
    @streaming_event.destroy
    redirect_to admin_streaming_events_url, notice: "Streaming event was successfully destroyed."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_streaming_event
    @streaming_event = StreamingEvent.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def streaming_event_params
    params.require(:streaming_event).permit(:title, :description, :starts_at, :ends_at, :featured, :youtube_id, :thumbnail_url)
  end
end
