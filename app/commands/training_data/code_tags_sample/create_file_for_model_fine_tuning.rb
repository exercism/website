class TrainingData::CodeTagsSample::CreateFileForModelFineTuning
  include Mandate

  def call
    open_file!
    write_messages_for_tags!
    write_messages_for_samples!
    file.path
  ensure
    close_file!
  end

  private
  attr_reader :file

  def open_file!
    @file = Tempfile.new(['fine-tune-model', '.jsonl'])
  end

  def write_messages_for_tags!
    write_message!(
      "What are EXERCISM_REPRESENTATION_TAGS?",
      "EXERCISM_REPRESENTATION_TAGS are a standardised set of programming concepts, paradigms and techniques used to tag code. They are always lowercase and snake-case. There are two parts to a tag, split by a colon. The first part is one of four categories (construct, technique, paradigm and uses) and the second part is a specific tag within that category." # rubocop:disable Layout/LineLength
    )

    %w[construct paradigm technique].each do |namespace|
      write_message!(
        "Return the EXERCISM_REPRESENTATION_TAGS that are in the #{namespace} category as a JSON aray under a top level key of tags.",
        { tags: tags_with_namespace(namespace) }.to_json
      )
    end

    site_tags.each do |tag, criteria|
      write_message!(
        "When should a solution be tagged with the `#{tag}` EXERCISM_REPRESENTATION_TAG?",
        "It should be assigned when the code #{criteria}."
      )

      write_message!(
        "Which EXERCISM_REPRESENTATION_TAG should be tagged when the code #{criteria}?",
        "`#{tag}`"
      )
    end
  end

  def write_messages_for_samples!
    samples.each do |sample|
      next if sample.code.blank?
      next if sample.tags.blank?

      write_messages_for_sample_tags!(sample)
      write_messages_for_incorrect_llm_tags!(sample) if sample.llm_tags.present?
      write_messages_for_missing_llm_tags!(sample) if sample.llm_tags.present?
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def samples
    TrainingData::CodeTagsSample.includes(:track).
      where(status: %i[community_checked admin_checked]).
      where.not(tags: nil)
  end

  def write_messages_for_sample_tags!(sample)
    instruction_text = <<~INSTRUCTION
      Respond with a JSON object containing one top-level key called tags containing an array of EXERCISM_REPRESENTATION_TAGS (programming concepts, paradigms and techniques) for this #{sample.track.title} code.

      ---

      #{sample.code}"
    INSTRUCTION

    write_message!(
      instruction_text.delete("\r"),
      sample.tags.to_json
    )
  end

  def write_messages_for_incorrect_llm_tags!(sample)
    incorrect_llm_tags = sample.llm_tags - sample.tags
    incorrect_llm_tags.each do |tag|
      criteria = site_tags[tag]
      next if criteria.blank?

      criteria = criteria.split
      criteria[0] = criteria[0].singularize
      criteria = criteria.join(' ')

      write_message!(
        "Given the following code, should it be assigned the `#{tag}` EXERCISM_REPRESENTATION_TAG, and why?\n#{sample.code}",
        "No, because it does not #{criteria}."
      )
    end
  end

  def write_messages_for_missing_llm_tags!(sample)
    missing_llm_tags = sample.tags - sample.llm_tags
    missing_llm_tags.each do |tag|
      criteria = site_tags[tag]
      next if criteria.blank?

      write_message!(
        "Given the following code, should it be assigned the `#{tag}` EXERCISM_REPRESENTATION_TAG, and why?\n#{sample.code}",
        "Yes, because it #{criteria}."
      )
    end
  end

  def write_message!(user, assistant)
    message = {
      messages: [
        { role: "system", "content": SYSTEM_TEXT },
        { role: "user", "content": user },
        { role: "assistant", "content": assistant }
      ]
    }

    file.write(message.to_json)
    file.write("\n")
  end

  def close_file!
    file.close
  end

  def tags_with_namespace(namespace)
    site_tags.keys.select { |tag| tag.starts_with?("#{namespace}:") }
  end

  memoize
  def site_tags = Site::Tag.pluck(:tag, :description).to_h

  SYSTEM_TEXT = 'You are a expert in EXERCISM_REPRESENTATION_TAGS'.freeze
  private_constant :SYSTEM_TEXT
end
