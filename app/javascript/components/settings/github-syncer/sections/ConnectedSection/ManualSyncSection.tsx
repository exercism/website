import React, { useCallback, useContext, useState } from 'react'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import { TrackSelect } from '@/components/common/TrackSelect'
import toast from 'react-hot-toast'
import { fetchWithParams } from '../../fetchWithParams'

type Track = {
  title: string
  slug: string | null
  iconUrl: string
}

export function ManualSyncSection() {
  const { tracks, links } = useContext(GitHubSyncerContext)
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
              `Your backup for the ${trackSlug} track has been queued. It should be completed within an hour.`
            )
          } else {
            const data = await response.json()
            toast.error(
              'Error queuing backup for the track: ' +
                (data.error?.message || 'Unknown error')
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

  const handleSyncEverything = useCallback(() => {
    fetchWithParams({
      url: links.syncEverything,
    })
      .then(async (response) => {
        if (response.ok) {
          toast.success(
            `Your backup for all tracks has been queued. It should be completed within an hour.`
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
  }, [links.syncEverything])

  return (
    <section id="manual-sync-section">
      <h2 className="!mb-6">Backup a track</h2>
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

      <button
        onClick={() => handleSyncSingleTrack(track.slug)}
        disabled={!track.slug}
        className="btn btn-primary"
      >
        Backup Track
      </button>

      <div className="border-t-1 border-borderColor6 my-32" />
      <h2 className="!mb-6">Backup everything</h2>

      <p className="text-16 leading-150 mb-12">
        If you want to backup all your exercises across all tracks to GitHub,
        you can use this function.
      </p>

      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">Note:</strong> Please use this
        sparingly, for example when you want to bootstrap a new repo. This is
        not designed to be part of your normal workflow.
      </p>
      <button onClick={handleSyncEverything} className="btn btn-primary">
        Backup Everything
      </button>
    </section>
  )
}
