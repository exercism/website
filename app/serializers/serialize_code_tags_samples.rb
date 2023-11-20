class SerializeCodeTagsSamples
  include Mandate

  initialize_with :samples, status: Mandate::NO_DEFAULT

  def call
    samples.includes(:track, :exercise).map do |sample|
      SerializeCodeTagsSample.(sample, status:)
    end
  end
end
