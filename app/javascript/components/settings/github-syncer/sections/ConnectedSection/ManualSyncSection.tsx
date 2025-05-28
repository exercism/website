import React, { useContext, useState } from 'react'
import { SectionHeader } from '../../common/SectionHeader'
import { GitHubSyncerContext } from '../../GitHubSyncerForm'
import Dropdown from '@/components/dropdowns/Dropdown'
import { TrackSelect } from '@/components/common/TrackSelect'
import { useLogger } from '@/components/bootcamp/common/hooks/useLogger'

type Track = {
  title: string
  slug: string | null
  iconUrl: string
}

export function ManualSyncSection() {
  const { tracks } = useContext(GitHubSyncerContext)
  useLogger('tracks', tracks)

  const [track, setTrack] = useState<Track>({} as Track)
  return (
    <section id="manual-sync-section">
      <h2 className="!mb-6">Backup a track</h2>
      <p className="text-16 leading-150 mb-12">
        If you want to backup a track to GitHub, you can use this function.
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
      <button className="btn btn-primary">Backup Everything</button>
    </section>
  )
}
