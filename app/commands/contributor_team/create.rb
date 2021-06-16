class ContributorTeam
  class Create
    include Mandate

    initialize_with :name, :attributes

    def call
      ContributorTeam.create_or_find_by!(name: name) do |t|
        t.attributes = attributes
      end
    end
  end
end
