import React from 'react'
import toast from 'react-hot-toast'
import { sendRequest } from '@/utils/send-request'
import { Iteration } from '../types'

// Syncer enabled + automatic: Say "Your solution will auto-backup to GitHub. If it does not for some reason, please click this button to manually start the backup."
export function ActiveAutomaticSync({
  syncIterationLink,
  iteration,
}: {
  syncIterationLink: string
  iteration: Iteration
}): JSX.Element {
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
        onClick={() =>
          handleSyncIteration({ endpoint: syncIterationLink, iteration })
        }
        className="btn btn-xs btn-primary"
      >
        Start backup
      </button>
    </div>
  )
}

export function handleSyncIteration({
  endpoint,
  iteration,
}: {
  endpoint: string
  iteration: Iteration
}) {
  const { fetch } = sendRequest({
    endpoint,
    method: 'PATCH',
    body: JSON.stringify({ iteration }),
  })

  fetch
    .then(async (response) => {
      if (response.ok) {
        toast.success(
          `Your backup for all tracks has been queued and should be completed within a few minutes.`,
          { duration: 5000 }
        )
      } else {
        const data = await response.json()
        toast.error(
          'Error queuing backup for all tracks: ' +
            (data.error?.message || 'Unknown error')
        )
      }
    })
    .catch((error) => {
      console.error('Error:', error)
      toast.error(
        'Something went wrong while queuing the backup for all tracks. Please try again.'
      )
    })
}
