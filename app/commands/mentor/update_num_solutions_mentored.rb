class Mentor::UpdateNumSolutionsMentored
  include Mandate

  initialize_with :mentor

  def call
    User::ResetCache.(mentor, :num_solutions_mentored)
    User::ResetCache.(mentor, :num_students_mentored)
  end
end
