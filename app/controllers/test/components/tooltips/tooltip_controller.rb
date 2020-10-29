class Test::Components::Tooltips::TooltipController < Test::BaseController
  def show; end

  def student
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    students = [
      {
        id: 1,
        avatar_url: "https://robohash.org/exercism",
        handle: "mentee",
        is_starred: true,
        have_mentored_previously: true,
        status: "First timer",
        updated_at: 1.year.ago.iso8601
      },
      {
        id: 2,
        avatar_url: "https://robohash.org/exercism_2",
        handle: "User 2",
        is_starred: false,
        have_mentored_previously: true,
        status: "First timer",
        updated_at: 1.week.ago.iso8601
      },
      {
        id: 3,
        avatar_url: "https://robohash.org/exercism_3",
        handle: "Frank",
        is_starred: false,
        have_mentored_previously: true,
        status: "First timer",
        updated_at: 1.week.ago.iso8601
      }
    ]

    student = students.detect { |s| s[:id] == params[:id].to_i }

    expires_in 1.minute
    render json: student
  end
end
