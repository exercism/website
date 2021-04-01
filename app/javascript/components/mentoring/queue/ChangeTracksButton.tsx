import React, { useState, useCallback, forwardRef } from 'react'
import { MentorChangeTracksModal } from '../../modals/MentorChangeTracksModal'
import { MentoredTrack } from '../../types'

export type Links = {
  tracks: string
  updateTracks: string
}

export type Props = {
  links: Links
  tracks: readonly MentoredTrack[]
  cacheKey: string
}

export const ChangeTracksButton = forwardRef<HTMLButtonElement, Props>(
  ({ links, tracks, cacheKey }, ref) => {
    const [open, setOpen] = useState(false)

    const handleSuccess = useCallback(() => {
      setOpen(false)
    }, [])

    return (
      <React.Fragment>
        <button
          ref={ref}
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
)
