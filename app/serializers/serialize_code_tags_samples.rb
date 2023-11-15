class SerializeCodeTagsSamples
  include Mandate

  initialize_with :samples

  def call
    samples.includes(:track, :exercise).map do |sample|
      SerializeCodeTagsSample.(sample)
    end
  end
end
