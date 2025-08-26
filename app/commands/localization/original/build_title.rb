class Localization::Original::BuildTitle < ApplicationCommand
  include Mandate
  initialize_with :original, :about

  def call
    if type.to_s.starts_with?("exercise_")
      "#{about.track.title} / #{about.title}"
    elsif type.to_s.starts_with?("concept_")
      "Concept: #{key.split(".").first.capitalize}"
    elsif type.to_s.starts_with?("generic_exericse_")
      "Generic Exercise: #{key.split(".").first.capitalize}"
    else
      type.to_s.humanize
    end
  end
end
