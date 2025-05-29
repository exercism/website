import React from 'react'
import { handleSyncIteration } from './ActiveAutomaticSync'
import { SyncIterationData } from './GithubSyncerWidget'

// Syncer enabled + manual: Say "You have automatic syncs disabled. Click to back up your solution".
export function ActiveManualSync({
  syncIterationLink,
  iteration,
}: {
  syncIterationLink: string
  iteration: SyncIterationData
}) {
  return (
    <div className="flex flex-col items-center py-24">
      <h6 className="font-semibold text-16 mb-16">
        You have automatic syncs disabled
      </h6>
      <button
        onClick={() =>
          handleSyncIteration({ endpoint: syncIterationLink, iteration })
        }
        className="btn btn-xs btn-primary"
      >
        Click to back up your solution
      </button>
    </div>
  )
}
