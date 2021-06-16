class ContributorTeam
  class Create
    include Mandate

    initialize_with :name, :attributes

    def call
      ContributorTeam.create_or_find_by!(
        name: name,
        **attributes
      )
    end
  end
end
