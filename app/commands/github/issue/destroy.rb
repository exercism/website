class Github::Issue::Destroy
  include Mandate

  initialize_with :node_id

  def call
    issue = ::Github::Issue.find_by!(node_id:)
    issue.destroy
  end
end
