module ComponentsHelper
  def example_iterations_summary_table(solution)
    react_component("example-iterations-summary-table", {
                      solution_id: solution.id,
                      iterations: solution.serialized_iterations
                    })
  end

  def maintaining_iterations_summary_table(iterations)
    react_component("maintaining-iterations-summary-table", {
                      iterations: iterations.map(&:serialized)
                    })
  end

  def notification_icon(user)
    react_component("notification-icon", { count: user.notifications.count })
  end

  def mentor_conversations_list(mentor)
    react_component("mentor-conversations-list", { conversations: mentor.conversations })
  end

  private
  def react_component(id, data)
    tag :div, {
      "data-react-#{id}": true,
      "data-react-data": data.to_json
    }
  end
end
