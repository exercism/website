import React from 'react'
import toast, { Toaster } from 'react-hot-toast'
import { SyncObj } from './GithubSyncerWidget'
import { GraphicalIcon } from '../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

// Syncer enabled + automatic: Say "Your solution will auto-backup to GitHub. If it does not for some reason, please click this button to manually start the backup."
export function ActiveAutomaticSync({ sync }: { sync: SyncObj }): JSX.Element {
  const { t } = useAppTranslation('components/github-syncer-widget')
  return (
    <div className="flex gap-24 items-start py-32 px-24">
      <GraphicalIcon icon="github-syncer" className="w-[72px]" />
      <div className="flex flex-col items-start ">
        <h6 className="font-semibold text-textColor1 text-21 mb-12">
          {t('activeAutomaticSync.autoBackupEnabled')}
        </h6>
        <p className="text-16 leading-150 mb-12">
          {sync.type === 'solution'
            ? t('activeAutomaticSync.newIterationsAutoBackupSolution')
            : t('activeAutomaticSync.newIterationsAutoBackupIteration')}
        </p>
        <button
          onClick={() => handleSync({ sync })}
          className="btn btn-s btn-secondary"
        >
          {sync.type === 'solution'
            ? t('activeAutomaticSync.triggerSolutionBackup')
            : t('activeAutomaticSync.triggerIterationBackup')}
        </button>
        <Toaster position="bottom-right" />
      </div>
    </div>
  )
}

export async function handleSync({ sync }: { sync: SyncObj }) {
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
