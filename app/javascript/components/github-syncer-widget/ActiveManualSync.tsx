import React from 'react'
import { handleSyncIteration } from './ActiveAutomaticSync'
import { SyncObj } from './GithubSyncerWidget'
import { Toaster } from 'react-hot-toast'

// Syncer enabled + manual: Say "You have automatic syncs disabled. Click to back up your solution".
export function ActiveManualSync({ sync }: { sync: SyncObj }) {
  return (
    <div className="flex flex-col items-center py-24">
      <h6 className="font-semibold text-16 mb-16">
        You have automatic syncs disabled
      </h6>
      <button
        onClick={() => handleSyncIteration({ sync })}
        className="btn btn-xs btn-primary"
      >
        Click to back up your solution
      </button>
      <Toaster position="bottom-right" />
    </div>
  )
}
