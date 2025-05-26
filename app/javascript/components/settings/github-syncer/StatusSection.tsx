import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useCallback } from 'react'
import { GitHubSyncerContext } from './GitHubSyncerForm'
import { fetchWithParams } from './fetchWithParams'

export function StatusSection() {
  const { links } = React.useContext(GitHubSyncerContext)

  return (
    <section>
      <h2>Status</h2>
      <p className="text-16 leading-140 mb-16">
        Your GitHub syncing is enabled and you are connected to this repo
      </p>
    </section>
  )
}
