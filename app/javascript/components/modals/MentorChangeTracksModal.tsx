import React, { useState } from 'react'
import { Modal, ModalProps } from './Modal'
import { TrackSelector } from '../mentoring/TrackSelector'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { MentoredTrack } from '../types'
import { APIResponse as TrackListAPIResponse } from '../mentoring/queue/useTrackList'
import { useQueryCache } from 'react-query'

type Links = {
  tracks: string
  updateTracks: string
}

export const MentorChangeTracksModal = ({
  onClose,
  tracks,
  cacheKey,
  links,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  links: Links
  tracks: readonly MentoredTrack[]
  cacheKey: string
  onSuccess: () => void
}): JSX.Element => {
  const queryCache = useQueryCache()
  const [selected, setSelected] = useState<string[]>(tracks.map((t) => t.slug))

  const [mutation] = useMutation<TrackListAPIResponse>(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.updateTracks,
        method: 'PATCH',
        body: JSON.stringify({ track_slugs: selected }),
      })

      return fetch
    },
    {
      onSuccess: (response) => {
        queryCache.setQueryData(cacheKey, response)
        onSuccess()
      },
      onSettled: () => {
        queryCache.invalidateQueries(cacheKey)
      },
    }
  )

  return (
    <Modal
      {...props}
      onClose={onClose}
      className="m-change-mentor-tracks"
      cover={false}
    >
      <header>
        <div className="info">
          <h2>Change the Tracks you mentor</h2>
          <p>
            You will still be able to continue any existing discussions on other
            tracks.
          </p>
        </div>
      </header>
      <TrackSelector
        selected={selected}
        setSelected={setSelected}
        tracksEndpoint={links.tracks}
        onContinue={() => mutation()}
      />
    </Modal>
  )
}
