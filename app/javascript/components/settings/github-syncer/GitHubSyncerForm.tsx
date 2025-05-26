import React from 'react'
import { ConnectToGithubSection } from './ConnectToGithubSection'
import { ConnectedSection } from './ConnectedSection'

export type GitHubSyncerFormProps = {
  links: { connectToGithub: string; settings: string }
  isUserConnected: boolean
  isUserActive: boolean
  repoFullName: string
}

type GitHubSyncerContextType = Omit<GitHubSyncerFormProps, 'isUserConnected'>

export const GitHubSyncerContext = React.createContext<GitHubSyncerContextType>(
  {} as GitHubSyncerContextType
)

export default function GitHubSyncerForm(
  data: GitHubSyncerFormProps
): JSX.Element {
  return (
    <GitHubSyncerContext.Provider
      value={{
        links: data.links,
        isUserActive: data.isUserActive,
        repoFullName: data.repoFullName,
      }}
    >
      {data.isUserConnected ? <ConnectedSection /> : <ConnectToGithubSection />}
    </GitHubSyncerContext.Provider>
  )
}
