class GenericExercise::CreateOrUpdate
  include Mandate

  initialize_with :slug, :title, :blurb, :source, :source_url, :deep_dive_youtube_id, :deep_dive_blurb, :status

  def call
    create!.tap do |exercise|
      exercise.update!(attributes)
    end
  end

  private
  def create!
    GenericExercise.find_create_or_find_by!(slug:) do |exercise|
      exercise.attributes = attributes
    end
  end

  def attributes = { title:, blurb:, source:, source_url:, deep_dive_youtube_id:, deep_dive_blurb:, status: }
end
