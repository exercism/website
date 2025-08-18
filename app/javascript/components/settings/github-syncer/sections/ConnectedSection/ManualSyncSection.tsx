import React, { useCallback, useContext, useState } from 'react'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { TrackSelect } from '@/components/common/TrackSelect'
import toast from 'react-hot-toast'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { StaticTooltip } from '@/components/bootcamp/JikiscriptExercisePage/Scrubber/ScrubberTooltipInformation'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type Track = {
  title: string
  slug: string | null
  iconUrl: string
}

export function ManualSyncSection() {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx'
  )
  const { tracks, links, isSyncingEnabled } = useContext(GitHubSyncerContext)
  const [track, setTrack] = useState<Track>({} as Track)

  const handleSyncSingleTrack = useCallback(
    (trackSlug: string | null) => {
      if (!trackSlug) return
      fetchWithParams({
        url: links.syncTrack + '?track_slug=' + trackSlug,
      })
        .then(async (response) => {
          if (response.ok) {
            toast.success(
              t(
                'yourBackupForTheTrackHasBeenQueuedAndShouldBeCompletedWithinAFewMinutes',
                { trackSlug }
              ),
              { duration: 5000 }
            )
          } else {
            await handleJsonErrorResponse(
              response,
              t('errorQueuingBackupForTheTrack')
            )
          }
        })
        .catch((error) => {
          console.error('Error:', error)
          toast.error(
            t('somethingWentWrongWhileQueuingTheBackupPleaseTryAgain')
          )
        })
    },
    [links.syncTrack, t]
  )

  return (
    <section
      style={{
        border: !isSyncingEnabled ? '2px solid #F69605' : '',
      }}
      id="manual-sync-section"
    >
      <h2 className="!mb-6">{t('backupATrack')}</h2>
      <p className="text-16 leading-150 mb-12">
        {t('ifYouWantToBackupATrackToGithubYouCanUseThisFunction')}
      </p>

      <p className="text-16 leading-150 mb-16">
        <Trans
          i18nKey="notePleaseUseThisSparing"
          ns="components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx"
          components={{ strong: <strong className="font-medium" /> }}
        />
      </p>

      <div className="mb-16">
        <div className="font-mono font-semibold text-14 mb-8">
          {t('selectTrackToBackup')}
        </div>
        <TrackSelect
          value={track}
          setValue={setTrack}
          tracks={tracks}
          size="multi"
        />
      </div>

      <div className="group relative">
        <button
          onClick={() => handleSyncSingleTrack(track.slug)}
          disabled={!track.slug || !isSyncingEnabled}
          className="btn btn-primary"
        >
          {t('backupTrack')}
        </button>
        {!isSyncingEnabled && (
          <StaticTooltip
            style={{ transform: 'translate(-25%, -100%)', left: 0 }}
            className="bg-textColor1 text-backgroundColorA opacity-90 rounded-8"
            text={t('syncingIsPausedEnableItToBackUpThisTrack')}
          />
        )}
      </div>
      <div className="border-t-1 border-borderColor6 my-32" />
      <h2 className="!mb-6">{t('backupEverything')}</h2>

      <p className="text-16 leading-150 mb-12">
        {t(
          'ifYouWantToBackupAllYourExercisesAcrossAllTracksToGithubYouCanUseThisFunction'
        )}
      </p>

      <p className="text-16 leading-150 mb-16">
        <Trans
          ns="components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx"
          components={{ strong: <strong className="font-medium" /> }}
          i18nKey="notePleaseUseThisSparingForExampleWhenYouWantToBootstrapANewRepoThisIsNotDesignedToBePartOfYourNormalWorkflow"
        />
      </p>
      <div className="group relative">
        <button
          disabled={!isSyncingEnabled}
          onClick={() =>
            handleSyncEverything({
              syncEverythingEndpoint: links.syncEverything,
            })
          }
          className="btn btn-primary relative group"
        >
          {t('backupEverythingLabel')}
        </button>
        {!isSyncingEnabled && (
          <StaticTooltip
            style={{ transform: 'translate(-25%, -100%)', left: 0 }}
            className="bg-textColor1 text-backgroundColorA opacity-90 rounded-8"
            text={t('syncingIsPausedEnableItToBackUpEverything')}
          />
        )}
      </div>
    </section>
  )
}

export function handleSyncEverything({
  syncEverythingEndpoint,
}: {
  syncEverythingEndpoint: string
}) {
  const { t } = useAppTranslation(
    'components/settings/github-syncer/sections/ConnectedSection/ManualSyncSection.tsx'
  )
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
}
