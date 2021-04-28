import React, { useState } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useMutation } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { FormButton } from '../../common/FormButton'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'

export const LeaveTrackButton = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button type="button" onClick={() => setOpen(true)}>
        Leave track
      </button>
      <LeaveTrackModal
        open={open}
        onClose={() => setOpen(false)}
        endpoint={endpoint}
      />
    </React.Fragment>
  )
}

type UserTrack = {
  links: {
    self: string
  }
}

const DEFAULT_ERROR = new Error('Unable to leave track')

export const LeaveTrackModal = ({
  endpoint,
  ...props
}: Omit<ModalProps, 'className'> & { endpoint: string }): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<UserTrack | undefined>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'POST',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<UserTrack>(json, 'userTrack')
      })
    },
    {
      onSuccess: (track) => {
        if (!track) {
          return
        }

        window.location.replace(track.links.self)
      },
    }
  )

  return (
    <Modal className="m-leave-track" {...props}>
      <FormButton onClick={() => mutation()} status={status}>
        Leave track
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
