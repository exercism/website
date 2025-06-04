import React, { SetStateAction, useState } from 'react'
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
  links: {
    connectToGithub: string
    settings: string
    syncTrack: string
    syncEverything: string
  }
  isUserConnected: boolean
  isUserInsider: boolean
  syncer: GithubSyncerSettings | null
  tracks: readonly { slug: string; title: string; iconUrl: string }[]
  defaultPathTemplate: string
  defaultCommitMessageTemplate: string
}

type GitHubSyncerContextType = Omit<
  GitHubSyncerFormProps,
  'isUserConnected'
> & {
  isSyncingEnabled: boolean
  setIsSyncingEnabled: React.Dispatch<SetStateAction<boolean>>
}

export const GitHubSyncerContext = React.createContext<GitHubSyncerContextType>(
  {} as GitHubSyncerContextType
)

export default function GitHubSyncerForm(
  data: GitHubSyncerFormProps
): JSX.Element {
  const [isSyncingEnabled, setIsSyncingEnabled] = useState(
    data.syncer?.enabled || false
  )
  return (
    <GitHubSyncerContext.Provider
      value={{
        links: data.links,
        isUserInsider: data.isUserInsider,
        syncer: data.syncer,
        tracks: data.tracks,
        defaultCommitMessageTemplate: data.defaultCommitMessageTemplate,
        defaultPathTemplate: data.defaultPathTemplate,
        isSyncingEnabled,
        setIsSyncingEnabled,
      }}
    >
      {data.isUserConnected ? <ConnectedSection /> : <ConnectToGithubSection />}
      <Toaster position="bottom-right" />
    </GitHubSyncerContext.Provider>
  )
}
