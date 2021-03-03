desc 'Sync authors and contributors'
task sync_authors_and_contributors: :environment do
  Git::SyncAuthorsAndContributors.call
end
