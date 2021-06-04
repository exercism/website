class AssembleTasks
  include Mandate

  initialize_with :params

  def call
    SerializePaginatedCollection.(
      tasks,
      serializer: SerializeTasks,
      meta: {
        unscoped_total: unscoped_total
      }
    )
  end

  memoize
  def unscoped_total
    ::Github::Task::Search.(
      actions: params[:actions],
      knowledge: params[:knowledge],
      areas: params[:areas],
      sizes: params[:sizes],
      types: params[:types],
      repo_url: params[:repo_url],
      track_id: params[:track_id],
      sorted: false,
      paginated: false
    ).count
  end

  memoize
  def tasks
    ::Github::Task::Search.(
      actions: params[:actions],
      knowledge: params[:knowledge],
      areas: params[:areas],
      sizes: params[:sizes],
      types: params[:types],
      repo_url: params[:repo_url],
      track_id: params[:track_id],
      order: params[:order],
      page: params[:page]
    )
  end
end
