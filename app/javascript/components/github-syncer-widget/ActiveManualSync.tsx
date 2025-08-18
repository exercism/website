import React from 'react'
import { handleSync } from './ActiveAutomaticSync'
import { SyncObj } from './GithubSyncerWidget'
import { Toaster } from 'react-hot-toast'
import { useAppTranslation } from '@/i18n/useAppTranslation'

// Syncer enabled + manual: Say "You have automatic syncs disabled. Click to back up your solution".
export function ActiveManualSync({ sync }: { sync: SyncObj }) {
  const { t } = useAppTranslation('components/github-syncer-widget')
  return (
    <div className="flex flex-col items-center py-24">
      <h6 className="font-semibold text-16 mb-16">
        {t('activeManualSync.automaticSyncsDisabled')}
      </h6>
      <button
        onClick={() => handleSync({ sync })}
        className="btn btn-xs btn-primary"
      >
        {t('activeManualSync.clickToBackupSolution')}
      </button>
      <Toaster position="bottom-right" />
    </div>
  )
}
