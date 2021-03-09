import React, { useState, useCallback } from 'react'
import { MentorChangeTracksModal } from '../../modals/MentorChangeTracksModal'
import { MentoredTrack } from './useTrackList'

export type Links = {
  tracks: string
  updateTracks: string
}

export const ChangeTracksButton = ({
  links,
  tracks,
  cacheKey,
}: {
  links: Links
  tracks: readonly MentoredTrack[]
  cacheKey: string
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  const handleSuccess = useCallback(() => {
    setOpen(false)
  }, [])

  return (
    <React.Fragment>
      <button
        type="button"
        onClick={() => {
          setOpen(true)
        }}
      >
        Change tracks
      </button>
      <MentorChangeTracksModal
        open={open}
        tracks={tracks}
        cacheKey={cacheKey}
        links={links}
        onClose={() => setOpen(false)}
        onSuccess={handleSuccess}
      />
    </React.Fragment>
  )
}
