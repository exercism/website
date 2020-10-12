module Test
  class SolutionsChannel < ApplicationCable::Channel
    def subscribed
      stream_for solution
    end

    def submit
      Test::SolutionsChannel.broadcast_to(solution, {
                                            status: "pass",
                                            tests: [
                                              { name: :test_a_name_given, status: :pass, output: "Hello" }
                                            ]
                                          })
    end

    private
    def solution
      @solution ||= Solution.first
    end
  end
end
