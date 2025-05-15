import React from 'react'
import { DangerZoneSection } from './DangerZoneSection'
import { ProcessingMethodSection } from './ProcessingMethodSection'
import { PathTemplateSection } from './PathTemplateSection'
import { CommitMessageTemplateSection } from './CommitMessageTemplateSection'

export type GitHubSyncerFormProps = {
  links: { connectToGithub: string; settings: string }
  isUserConnected: boolean
  isUserActive: boolean
}

type GitHubSyncerContextType = {
  links: GitHubSyncerFormProps['links']
  isUserActive: GitHubSyncerFormProps['isUserActive']
}
export const GitHubSyncerContext = React.createContext<GitHubSyncerContextType>(
  {} as GitHubSyncerContextType
)

export default function GitHubSyncerForm(
  data: GitHubSyncerFormProps
): JSX.Element {
  console.log('DATA', data)

  return (
    <GitHubSyncerContext.Provider
      value={{ links: data.links, isUserActive: data.isUserActive }}
    >
      {data.isUserConnected ? <ConnectedSection /> : <ConnectToGithubSection />}
    </GitHubSyncerContext.Provider>
  )
}

function ConnectToGithubSection() {
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

function ConnectedSection() {
  return (
    <>
      <ProcessingMethodSection />
      <PathTemplateSection />
      <CommitMessageTemplateSection />
      <DangerZoneSection />
    </>
  )
}
