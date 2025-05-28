import React, { useCallback, useContext, useState } from 'react'
import { SectionHeader } from '../../common/SectionHeader'
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
  const { tracks, isUserInsider, links } = useContext(GitHubSyncerContext)
  const [track, setTrack] = useState<Track>({} as Track)

  const handleBackup = useCallback(() => {
    if (!isUserInsider) return
    fetchWithParams({
      // Use the correct link
      url: links.settings,
      // params: {
      //   commit_message_template: template,
      // },
    })
      .then(async (response) => {
        if (response.ok) {
          toast.success(
            'Sync scheduled successfully! This should complete in the next hour.'
          )
        } else {
          const data = await response.json()
          toast.error(
            'Failed to schedule syncing: ' + data.error.message ||
              'Unknown error'
          )
        }
      })
      .catch((error) => {
        console.error('Error:', error)
        toast.error(
          'Something went wrong while scheduling syncing. Please try again.'
        )
      })
  }, [links.settings, isUserInsider])

  return (
    <section id="manual-sync-section">
      <SectionHeader title="Manual Backup" />

      <h3 className="text-20 font-semibold mt-10 mb-12">Backup a track</h3>
      <p className="text-16 leading-150 mb-16">
        If you want to backup a full track to GitHub, you can use this function.
      </p>

      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">Note:</strong> Please use this
        sparingly, for example when you want to bootstrap a new repo. This is
        not designed to be part of your normal workflow.
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

      <button disabled={!track.slug} className="btn btn-primary">
        Backup Track
      </button>

      <div className="border-t-1 border-borderColor6 my-32" />
      <h3 className="text-20 font-semibold mt-10 mb-12">Backup everything</h3>

      <p className="text-16 leading-150 mb-12">
        If you want to backup all your exercises across all tracks to GitHub,
        you can use this function.
      </p>

      <p className="text-16 leading-150 mb-16">
        <strong className="font-medium">Note:</strong> Please use this
        sparingly, for example when you want to bootstrap a new repo. This is
        not designed to be part of your normal workflow.
      </p>
      <button className="btn btn-primary">Backup Everything</button>
    </section>
  )
}
