import React from 'react'
import { GitHubSyncerContext } from '../GitHubSyncerForm'

export function ConnectToGithubSection() {
  const { links } = React.useContext(GitHubSyncerContext)
  return (
    <section>
      <h2>Connect to GitHub</h2>
      <p className="text-16 leading-140 mb-16">
        Connect to GitHub to sync your repositories.
      </p>
      <a className="btn btn-primary w-fit" href={links?.connectToGithub}>
        Connect to GitHub repo
      </a>
    </section>
  )
}
