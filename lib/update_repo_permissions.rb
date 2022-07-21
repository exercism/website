def repositories_with_tag(tag)
  Exercism.octokit_client.
    search_repositories("org:exercism topic:#{tag}").
    items.
    map(&:full_name).
    sort
end

# track_repositories = repositories_with_tag('exercism-track')
# tooling_repositories = repositories_with_tag('exercism-tooling')
