import React from 'react'
import { ConnectedSection } from './sections/ConnectedSection'
import { Toaster } from 'react-hot-toast'
import { ConnectToGithubSection } from './sections/ConnectToGithubSection'

export type GithubSyncerSettings = {
  enabled: boolean
  repoFullName: string
  syncOnIterationCreation: boolean
  syncExerciseFiles: boolean
  processingMethod: 'commit' | 'pull_request'
  mainBranchName: string
  commitMessageTemplate: string
  pathTemplate: string
}

export type GitHubSyncerFormProps = {
  links: { connectToGithub: string; settings: string }
  isUserConnected: boolean
  isUserInsider: boolean
  syncer: GithubSyncerSettings | null
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
        isUserInsider: data.isUserInsider,
        syncer: data.syncer,
        tracks: data.tracks,
      }}
    >
      {data.isUserConnected ? <ConnectedSection /> : <ConnectToGithubSection />}
      <Toaster position="bottom-right" />
    </GitHubSyncerContext.Provider>
  )
}
