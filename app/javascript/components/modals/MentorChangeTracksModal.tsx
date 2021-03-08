import React, { useState } from 'react'
import { Modal, ModalProps } from './Modal'
import { ChooseTrackStep } from './mentor-registration-modal/ChooseTrackStep'
import { CloseButton } from './mentor-registration-modal/CloseButton'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { APIResponse as TrackListAPIResponse } from '../mentoring/queue/useTrackList'
import { queryCache } from 'react-query'

type Links = {
  tracks: string
  updateTracks: string
}

export const MentorChangeTracksModal = ({
  onClose,
  cacheKey,
  links,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  links: Links
  cacheKey: string
  onSuccess: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [selected, setSelected] = useState<string[]>([])

  const [mutation] = useMutation<TrackListAPIResponse>(
    () => {
      return sendRequest({
        endpoint: links.updateTracks,
        method: 'PATCH',
        body: JSON.stringify({ track_slugs: selected }),
        isMountedRef: isMountedRef,
      })
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
      className="m-become-mentor"
      cover={true}
    >
      <div className="md-container">
        <header>
          <CloseButton onClick={onClose} />
        </header>
        <ChooseTrackStep
          selected={selected}
          setSelected={setSelected}
          links={links}
          onContinue={() => mutation()}
        />
      </div>
    </Modal>
  )
}
