class User::ReputationToken < ApplicationRecord
  before_create do
    self.uniqueness_key = "#{user_id}|#{type_key}|#{guard_params}"

    self.version = latest_i18n_version
    self.uuid = SecureRandom.compact_uuid
  end

  def text
    # TODO: Add test for sanitizing here.
    I18n.t(
      "notifications.#{i18n_key}.#{version}",
      i18n_params.transform_values { |v| sanitize(v) }
    ).strip
  end

  def type_key
    type.split("::").last.underscore.split("_notification").first.to_sym
  end
end
# CATEGORIES = %i[
#   building
#   authoring
#   mentoring
# ].freeze
# private_constant :CATEGORIES

# REASON_VALUES = {
#   'authored_exercise': 10,
#   'contributed_to_exercise': 5,
#   'contributed_code/minor': 5,
#   'contributed_code/regular': 10,
#   'contributed_code/major': 15,
#   'mentored': 10,
#   'reviewed_code': 3
# }.with_indifferent_access.freeze
# private_constant :REASON_VALUES

# belongs_to :user
# belongs_to :track, optional: true
# belongs_to :exercise, optional: true
# belongs_to :context, polymorphic: true, optional: true

# validates :category, inclusion: {
#   in: CATEGORIES,
#   message: "%<value>s is not a valid category",
#   strict: ReputationTokenCategoryInvalid
# }

# validates :reason, inclusion: {
#   in: REASON_VALUES.keys,
#   message: "%<value>s is not a valid reason",
#   strict: ReputationTokenReasonInvalid
# }

# before_save do
#   self.value = REASON_VALUES[self.reason]
# end

# before_create do
#   self.uuid = SecureRandom.compact_uuid
# end

# after_save do
#   # We're updating in a single query instead of two queries to avoid race-conditions
#   summing_sql = Arel.sql("(#{user.reputation_tokens.select('SUM(value)').to_sql})")
#   User.where(id: user.id).update_all(reputation: summing_sql)
# end

# def category
#   super.to_sym
# end

# def icon_name
#   return exercise.icon_name if exercise
#   return track.icon_name if track

#   :reputation # TODO: Choose an icon
# end

# def description
#   case reason.split("/").first.to_sym
#   when :authored_exercise
#     "You authored #{exercise.title}"
#   when :contributed_to_exercise
#     "You conributed to #{exercise.title}"
#   when :contributed_code
#     "You contributed code"
#   when :mentored
#     "You mentored @#{context.student.handle} on #{context.exercise.title}"
#   when :reviewed_code
#     "You reviewed a Pull Request"
#   else
#     "You contributed to Exercism"
#   end
# rescue StandardError
#   "You contributed to Exercism"
# end

# def internal_link
#   nil
# end
# end
