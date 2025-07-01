import React, { useCallback, useContext, useState } from 'react'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { TrackSelect } from '@/components/common/TrackSelect'
import toast from 'react-hot-toast'
import { fetchWithParams, handleJsonErrorResponse } from '../../fetchWithParams'
import { StaticTooltip } from '@/components/bootcamp/JikiscriptExercisePage/Scrubber/ScrubberTooltipInformation'

type Track = {
  title: string
  slug: string | null
  iconUrl: string
}

export function ManualSyncSection() {
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
              `Your backup for the ${trackSlug} track has been queued and should be completed within a few minutes.`,
              { duration: 5000 }
            )
          } else {
            await handleJsonErrorResponse(
              response,
              'Error queuing backup for the track.'
            )
          }
        })
        .catch((error) => {
          console.error('Error:', error)
          toast.error(
            'Something went wrong while queuing the backup. Please try again.'
          )
        })
    },
    [links.syncTrack]
  )

  return (
    <section
      style={{
        border: !isSyncingEnabled ? '2px solid #F69605' : '',
      }}
      id="manual-sync-section"
    >
      <h2 className="mb-6!">Backup a track</h2>
      <p className="text-16 leading-150 mb-12">
        If you want to backup a track to GitHub, you can use this function.
      </p>

      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">Note:</strong> Please use this
        sparingly, for example when you want to backup a track for the first
        time. This is not designed to be part of your normal workflow and will
        likely hit rate-limits if over-used.
      </p>

      <div className="mb-16">
        <div className="font-mono font-semibold text-14 mb-8">
          Select track to backup
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
          Backup Track
        </button>
        {!isSyncingEnabled && (
          <StaticTooltip
            style={{ transform: 'translate(-25%, -100%)', left: 0 }}
            className="bg-textColor1 text-backgroundColorA opacity-90 rounded-8"
            text="Syncing is paused. Enable it to back up this track."
          />
        )}
      </div>
      <div className="border-t-1 border-borderColor6 my-32" />
      <h2 className="mb-6!">Backup everything</h2>

      <p className="text-16 leading-150 mb-12">
        If you want to backup all your exercises across all tracks to GitHub,
        you can use this function.
      </p>

      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">Note:</strong> Please use this
        sparingly, for example when you want to bootstrap a new repo. This is
        not designed to be part of your normal workflow.
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
          Backup Everything
        </button>
        {!isSyncingEnabled && (
          <StaticTooltip
            style={{ transform: 'translate(-25%, -100%)', left: 0 }}
            className="bg-textColor1 text-backgroundColorA opacity-90 rounded-8"
            text="Syncing is paused. Enable it to back up everything."
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
  fetchWithParams({
    url: syncEverythingEndpoint,
  })
    .then(async (response) => {
      if (response.ok) {
        toast.success(
          `Your backup for all tracks has been queued and should be completed within a few minutes.`,
          { duration: 5000 }
        )
      } else {
        await handleJsonErrorResponse(
          response,
          'Error queuing backup for all tracks.'
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
