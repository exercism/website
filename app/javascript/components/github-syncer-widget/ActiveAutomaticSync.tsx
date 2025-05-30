import React from 'react'
import toast, { Toaster } from 'react-hot-toast'
import { sendRequest } from '@/utils/send-request'
import { SyncObj } from './GithubSyncerWidget'

// Syncer enabled + automatic: Say "Your solution will auto-backup to GitHub. If it does not for some reason, please click this button to manually start the backup."
export function ActiveAutomaticSync({ sync }: { sync: SyncObj }): JSX.Element {
  return (
    <div className="flex flex-col items-center py-24">
      <h6 className="font-semibold text-16 mb-16">
        Your solution will auto-backup to GitHub.
      </h6>
      <p className="text-center text-balance mb-16">
        If it does not for some reason, please click this button to manually
        start the backup.
      </p>
      <button
        onClick={() => handleSyncIteration({ sync })}
        className="btn btn-xs btn-primary"
      >
        Start backup
      </button>
      <Toaster position="bottom-right" />
    </div>
  )
}

export async function handleSyncIteration({ sync }: { sync: SyncObj }) {
  try {
    const response = await fetch(sync.endpoint, {
      method: 'PATCH',
      body: sync.body,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    })

    if (!response.ok) {
      const text = await response.text()
      let errorMessage = 'Unknown error'

      if (text) {
        try {
          const data = JSON.parse(text)
          errorMessage = data.error?.message || errorMessage
        } catch {}
      }

      toast.error(`Error queuing backup for all tracks: ${errorMessage}`)
      return
    }

    toast.success(
      `Your backup has been queued and should be completed within a few minutes.`,
      { duration: 5000 }
    )
  } catch (error) {
    console.error('Error:', error)
    toast.error(
      'Something went wrong while queuing the backup for all tracks. Please try again.'
    )
  }
}
