desc 'Sync organization members'
task sync_organization_members: :environment do
  Github::OrganizationMember::SyncMembers.()
end
