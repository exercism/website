class API::HiringController < API::BaseController
  skip_before_action :authenticate_user!

  def testimonials
    user = User.find_by(handle: 'bobahop')
    testimonials = user.mentor_testimonials.published.joins(solution: { exercise: :track })
    testimonials = testimonials.where('exercises.track_id': Track.find(params[:track]).id) if params[:track]
    testimonials = testimonials.where('exercises.title LIKE ?', "%#{params[:exercise]}%") if params[:exercise]
    testimonials = testimonials.order(id: params[:order] == "newest_first" ? :desc : :asc)
    testimonials = testimonials.page(params[:page]).per(20)

    track_slugs = user.mentor_testimonials.published.joins(solution: { exercise: :track }).distinct.pluck('tracks.slug')
    track_counts = user.mentor_testimonials.published.joins(solution: { exercise: :track }).group('tracks.slug').count

    serialized = {
      results: testimonials.map do |t|
                 {
                   id: t.id,
                   track: {
                     slug: t.track.slug,
                     title: t.track.title,
                     icon_url: t.track.icon_url
                   },
                   exercise: {
                     slug: t.exercise.slug,
                     title: t.exercise.title,
                     icon_url: t.exercise.icon_url
                   },
                   mentor: {
                     handle: t.student.handle,
                     avatar_url: t.student.avatar_url
                   },
                   content: t.content,
                   created_at: t.created_at
                 }
               end,
      pagination: {
        current_page: testimonials.current_page,
        total_count: testimonials.total_count,
        total_pages: testimonials.total_pages
      },
      tracks: track_slugs,
      track_counts:
    }

    render json: { testimonials: serialized }
  end
end
