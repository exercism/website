class User::GithubSolutionSyncer < ApplicationRecord
  belongs_to :user

  validates :installation_id, :repo_full_name, presence: true

  enum processing_method: { commit: 1, pull_request: 2 }

  before_create do
    self.commit_message_template = DEFAULT_COMMIT_MESSAGE_TEMPLATE unless self.commit_message_template.present?
    self.path_template = DEFAULT_PATH_TEMPLATE unless self.path_template.present?
    self.processing_method = :pull_request
    self.sync_on_iteration_creation = true unless self.sync_on_iteration_creation == false
    self.sync_exercise_files = false unless self.sync_exercise_files.present?
  end

  def processing_method = super.to_sym
  def commit_to_main? = processing_method == :commit
  def create_pr? = processing_method == :pull_request

  DEFAULT_COMMIT_MESSAGE_TEMPLATE = "[Sync $sync_object] $track_slug/$exercise_slug/$iteration_idx".freeze
  DEFAULT_PATH_TEMPLATE = "solutions/$track_slug/$exercise_slug/$iteration_idx".freeze
end
