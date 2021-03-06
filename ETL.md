# ETL

## TODOs

- Add index to users.uid for Erik's usersnames script

This is how to do v2 - v3 ETL

0. Change config/database.yml
1. Load data into mysql

```bash
mysql -u root -e "drop database website_etl2"
mysql -u root -e "create database website_etl2"
mysql -u root website_etl2 < ../dump-for-v3-etl.sql
```

2. Run ETL

```bash
rails r 'require_relative Rails.root.join("lib/v2_etl/migrate"); V2ETL::Migrate.call'
```

3. Fix up Nim
4. Rename reasonml (https://github.com/exercism/reasonml/pull/135)
5. Import GitHub Usernames
6. `bundle exec rake sync_pull_requests_reputation`
7. `bundle exec rake sync_authors_and_contributors`
8. Iteration.find_each {|i|GenerateIterationSnippetJob.perform_later(i)}
9. Import contributor teams (tracks/reviewers/tooling teams)
10. Import contributor team members (see https://github.com/exercism/ErikSchierboom/blob/main/fsharp-scripts/Scripts/AnalyzeMaintainers.fs)
11. Remove unneeded teams
12. Fix submission filenames

```
# Create regular expression to match one of the track slugs
track_slugs = Track.pluck(:slug).map {|slug| Regexp.escape(slug)}
track_slug_regex_match = "(#{track_slugs.join('|')})"

files_to_upsert = []

Submission::File.find_each do |file|
    sanitized_file = file.filename
    .gsub(/\\+/, '/') # Replace one or more consecutive backslashes with one slash
    .gsub(/.*?\/#{track_slug_regex_match}\/[^\/]+\/(.+)/, '\2') # Strip off everything before and including the <track>/<exercise> part of the path
    .gsub(/^\//, '') # Remove leading slash

    next if file.filename == sanitized_file

    files_to_upsert << file.attributes.symbolize_keys.merge(filename: sanitized_file)
end

Submission::File.upsert_all(files_to_upsert)
```
