class AssembleStreamingEvents
  include Mandate

  initialize_with :params

  def self.events_per_page = 20
  def self.keys = %i[page per_page live]

  def call = SerializePaginatedCollection.(events, serializer: SerializeStreamingEvents)

  private
  memoize
  def events
    rows = live? ? StreamingEvent.live : StreamingEvent.scheduled
    rows.order(:starts_at).page(page).per(per_page)
  end

  def live? = params[:live].present?
  def page = params.fetch(:page, 1).to_i
  def per_page = params.fetch(:per_page, self.class.events_per_page).to_i
end
