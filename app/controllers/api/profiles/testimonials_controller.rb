module API::Profiles
  class TestimonialsController < BaseController
    def index
      render json: AssembleProfileTestimonialsList.(@user)
    end

    def hiring
      testimonials = @user.mentor_testimonials.published.joins(solution: { exercise: :track })
      testimonials = testimonials.where('exercises.track_id': Track.find(params[:track])) if params[:track]
      testimonials = testimonials.where('exercises.title LIKE ?': "%#{params[:track]}%") if params[:exercise]
      testimonials = testimonials.order(id: params[:order] == "newest_first" ? :desc : :asc)
      testimonials = testimonials.page(params[:page]).per(20)

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
                     author: {
                       handle: t.student.handle,
                       avatar_url: t.student.avatar_url
                     },
                     content: t.content,
                     created_at: t.created_at
                   }
                 end,
        meta: {
          current_page: testimonials.current_page,
          total_count: testimonials.total_count,
          total_pages: testimonials.total_pages
        }
      }

      render json: { testimonials: serialized }
    end
  end
end
