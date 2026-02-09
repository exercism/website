import { useCallback } from 'react'
import toast from 'react-hot-toast'
import { fetchWithParams, handleJsonErrorResponse } from './fetchWithParams'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function useSyncEverything(syncEverythingEndpoint: string) {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx'
  )

  return useCallback(() => {
    fetchWithParams({
      url: syncEverythingEndpoint,
    })
      .then(async (response) => {
        if (response.ok) {
          toast.success(
            t(
              'yourBackupForAllTracksHasBeenQueuedAndShouldBeCompletedWithinAFewMinutes'
            ),
            { duration: 5000 }
          )
        } else {
          await handleJsonErrorResponse(
            response,
            t('errorQueuingBackupForAllTracks')
          )
        }
      })
      .catch((error) => {
        console.error('Error:', error)
        toast.error(
          t('somethingWentWrongWhileQueuingTheBackupForAllTracksPleaseTryAgain')
        )
      })
  }, [syncEverythingEndpoint, t])
}
