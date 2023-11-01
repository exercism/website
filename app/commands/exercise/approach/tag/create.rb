class Exercise::Approach::Tag::Create
  include Mandate

  initialize_with :approach, :tag, :condition_type

  def call
    approach.tags.find_create_or_find_by!(tag:).tap do |approach_tag|
      approach_tag.update(condition_type:)
    end
  end
end
