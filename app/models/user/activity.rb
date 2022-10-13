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
  belongs_to :solution, optional: true

  def cacheable_rendering_data
    {
      text:,
      url:,
      icon_name:
    }
  end

  def non_cacheable_rendering_data = super.merge(occurred_at:)

  private
  # This should be overriden by child-classes
  def icon_name = "editor"
end
