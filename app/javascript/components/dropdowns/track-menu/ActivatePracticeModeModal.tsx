import React, { useState } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useMutation } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { FormButton, GraphicalIcon } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'

type UserTrack = {
  links: {
    self: string
  }
}

const DEFAULT_ERROR = new Error('Unable to switch to practice mode')

export const ActivatePracticeModeModal = ({
  endpoint,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & { endpoint: string }): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<UserTrack | undefined>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
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
    <Modal className="m-activate-practice-mode" onClose={onClose} {...props}>
      <GraphicalIcon icon="practice-mode" category="graphics" />
      <h2>Activate Practice Mode</h2>
      <p>
        Activating Practice Mode will unlock all the Practice Exercises on this
        track, but will disable Concepts and Learning exercises.
      </p>
      <div className="warning">
        You can switch in and out of practice mode at any time.
      </div>

      <FormButton
        onClick={() => mutation()}
        status={status}
        className="btn-primary btn-m"
      >
        Activate practice mode
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
