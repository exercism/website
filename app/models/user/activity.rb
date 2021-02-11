# Activities are also expected to define the following:
# - url
# - guard_params (a list of params that ensure we don't get duplicates
# for the same object. Normally the object that this activity is about
# surfices)
class User::Activity < ApplicationRecord
  extend Mandate::Memoize

  include IsParamaterisedSTI
  self.class_suffix = :activity
  self.i18n_category = :user_activities

  belongs_to :user
  belongs_to :track, optional: true
  belongs_to :solution, optional: true

  before_create do
    self.rendering_data_cache = cachable_rendering_data
  end

  def rendering_data
    data = rendering_data_cache
    if data.blank?
      data = cachable_rendering_data
      update!(rendering_data_cache: data)
    end

    data.with_indifferent_access.
      # This is not cachable as it is set in the before_create
      # However, we don't put it in non_cachable_rendering_data
      # so that that method can be overriden without consequence
      # or the need to call super and merge
      merge('occurred_at' => occurred_at).
      merge(non_cachable_rendering_data)
  end

  # This maps
  # {discussion: Solution::MentorDiscussion.find(186)}
  # to
  # {discussion: "gid://exercism/Solution::MentorDiscussion/186"}
  #
  # Any non-object params are left as the were passed in.
  def params=(hash)
    @input_params = hash
    self[:params] = hash.transform_values do |v|
      v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v
    end
  end

  def cachable_rendering_data
    {
      text: text,
      url: url,
      icon_name: icon_name
    }
  end

  def non_cachable_rendering_data
    {}
  end

  private
  # This should be overriden by child-classes
  def icon_name
    "editor"
  end
end
