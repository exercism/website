module Mentor
  class UpdateRoles
    include Mandate

    initialize_with :mentor

    def call
      if supermentor?
        mentor.update(roles: mentor.roles.add(Mentor::Supermentor::ROLE))
      else
        mentor.update(roles: mentor.roles.delete(Mentor::Supermentor::ROLE))
      end
    end

    private
    def supermentor? = Mentor::Supermentor.eligible?(mentor)
  end
end
