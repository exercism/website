class HandleFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    record.errors.add(attribute, "must have only letters, numbers, or hyphens.") unless /^[a-zA-Z0-9-]+$/.match?(value)
  end
end
