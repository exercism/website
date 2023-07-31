class Solution::Comment::Create
  include Mandate
  initialize_with :author, :solution, :content_markdown

  def call
    guard!

    begin
      solution.comments.create!(
        author:,
        content_markdown:
      ).tap do |comment|
        # TODO: (Required) Notifications

        # TODO: (Requried) Add this
        # CommentListChannel.notify!(@solution)
      end
    rescue ActiveRecord::RecordNotUnique
      # TODO: (Required) - Hash the comment and the solution,
      # add as an index, and return here.

      # solution_class.find_by!(
      #   user: user,
      #   exercise: exercise
      # )
    end
  end

  private
  def guard!
    # TODO: Check solution is accepting comments
  end
end
