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
      <SectionHeader title="Manual sync" />

      <h3 className="text-18 font-semibold mb-8">Sync track</h3>
      <p className="text-16 leading-150 mb-16">
        If you want to fully sync a track to GitHub, you can use this function.
        Please do this sparingly - e.g. for bootstrapping a new repo. This
        should not be part of a normal workflow!
      </p>

      <div className="mb-16">
        <div className="font-mono font-semibold text-14 mb-8">
          Select track to sync
        </div>
        <TrackSelect
          value={track}
          setValue={setTrack}
          tracks={tracks}
          size="multi"
        />
      </div>

      <button disabled={!track.slug} className="btn btn-primary">
        Sync
      </button>

      <div className="border-t-1 border-borderColor6 my-32" />

      <h3 className="text-18 font-semibold mb-8">Sync everything</h3>

      <p className="text-16 leading-150 mb-16">
        If you want to fully sync all your exercises across all tracks to
        GitHub, you can use this function. Please do this sparingly - e.g. for
        bootstrapping a new repo. This should not be part of a normal workflow!
      </p>
      <button className="btn btn-primary">Sync</button>
    </section>
  )
}
