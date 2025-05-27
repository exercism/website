import React from 'react'
import { ConnectedSection } from './sections/ConnectedSection'
import { Toaster } from 'react-hot-toast'
import { ConnectToGithubSection } from './sections/ConnectToGithubSection'

export type GitHubSyncerFormProps = {
  links: { connectToGithub: string; settings: string }
  isUserConnected: boolean
  isUserActive: boolean
  repoFullName: string
  isUserInsider: boolean
  tracks: readonly { slug: string; title: string; iconUrl: string }[]
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
        isUserInsider: data.isUserInsider,
        tracks: data.tracks,
      }}
    >
      {data.isUserConnected ? <ConnectedSection /> : <ConnectToGithubSection />}
      <Toaster position="bottom-right" />
    </GitHubSyncerContext.Provider>
  )
}
