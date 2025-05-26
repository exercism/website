class User::GithubSolutionSyncer < ApplicationRecord
  belongs_to :user

  validates :installation_id, :repo_full_name, presence: true

  enum processing_method: { commit: 1, pr: 2 }

  before_create do
    self.commit_message_template = "[Add Iteration] $track_slug/$exercise_slug/$iteration_idx" unless self.commit_message_template.present? # rubocop:disable Layout/LineLength
    self.path_template = "solutions/$track_slug/$exercise_slug/$iteration_idx" unless self.path_template.present?
    self.processing_method = :pr unless self.processing_method.present?
    self.sync_on_iteration_creation = true unless self.sync_on_iteration_creation == false
    self.sync_exercise_files = false unless self.sync_exercise_files.present?
  end

  def processing_method = super.to_sym
  def commit_to_main? = processing_method == :commit
  def create_pr? = processing_method == :pr
end
