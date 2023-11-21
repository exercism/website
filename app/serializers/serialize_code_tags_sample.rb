class SerializeCodeTagsSample
  include Mandate

  initialize_with :sample, status: Mandate::NO_DEFAULT

  def call
    {
      uuid: sample.uuid,
      status: sample.status,
      track: {
        title: track.title,
        icon_url: track.icon_url
      },
      exercise: {
        title: exercise.title,
        icon_url: exercise.icon_url
      },
      links: {
        edit: Exercism::Routes.training_data_code_tags_sample_url(sample, status:)
      }
    }
  end

  delegate :exercise, to: :sample
  delegate :track, to: :sample
end
