# ETL

## TODOs

- Add index to users.uid for Erik's usernames script

This is how to do v2 - v3 ETL

1. Change config/database.yml
2. Load data into mysql

```bash
mysql -u root -e "drop database website_etl2"
mysql -u root -e "create database website_etl2"
mysql -u root website_etl2 < ../dump-for-v3-etl.sql
mysql -u root -e "GRANT ALL PRIVILEGES ON website_etl2.* TO 'exercism_v3'@'localhost';"
```

3. Run ETL

```bash
rails r 'require_relative Rails.root.join("lib/v2_etl/migrate"); V2ETL::Migrate.call'
```

4. Import GitHub Usernames

```bash
mysql -u root website_etl2 < ../github_usernames.sql
```

5. Take snapshot
6. Fix up Nim (https://github.com/exercism/reasonml/issues/162)
7. Rename reasonml (https://github.com/exercism/reasonml/issues/162)

8. `bundle exec rails r 'Track.all.each { |t| SyncTrack.(t, force_sync: true) }'`
9. Take snapshot

10. Take snapshot
11. Deploy

12. `bundle exec rails r SyncBlogJob.perform_later`
13. `bundle exec rails r SyncDocsJob.perform_later`
14. `bundle exec rails r UpdateWebsiteCopyJob.perform_later`
15. `bundle exec rails r SyncIssuesAndTasksJob.perform_later`
16. `bundle exec rails r SyncTracksJob.perform_later`
17. `bundle exec rails r FetchAndSyncAllPullRequestsReputationJob`
18. `Iteration.find_each {|i|GenerateIterationSnippetJob.perform_later(i)}`

19. Sort teams

- Import contributor teams (tracks/reviewers/tooling teams)
- Import contributor team members (see https://github.com/exercism/ErikSchierboom/blob/main/fsharp-scripts/Scripts/AnalyzeMaintainers.fs)
- Remove unneeded teams

20. Schedule jobs

- Snippets for everything
- UpdateMentorStatsJob for all users who have mentored something
- Update counter caches for mentor_discussions posts

## Cleanup Things to consider

```ruby
connection.remove_column :solutions, :approved_by_id
connection.remove_column :solutions, :mentoring_requested_at
```

Move `users.default_allow_comments` to a new `preferences` table?
