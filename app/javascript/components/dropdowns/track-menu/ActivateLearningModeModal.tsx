import React, { useState } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { FormButton, GraphicalIcon } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'

type UserTrack = {
  links: {
    self: string
  }
}

const DEFAULT_ERROR = new Error('Unable to switch to learning mode')

export const ActivateLearningModeModal = ({
  endpoint,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & { endpoint: string }): JSX.Element => {
  const [mutation, { status, error }] = useMutation<UserTrack | undefined>(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })
      return fetch.then((json) => {
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
    <Modal className="m-activate-learning-mode" onClose={onClose} {...props}>
      <GraphicalIcon icon="learning-mode" category="graphics" />
      <h2>Activate Learning Mode</h2>
      <p>
        Activating Learning Mode will enable Concepts and Learning Exercises on
        this track, but will lock Exercises that you've not yet complete
        prerequisites for. You will still have access to any exercises you have
        started.
      </p>
      <div className="warning">
        You can switch in and out of Learning Mode at any time.
      </div>

      <FormButton
        onClick={() => mutation()}
        status={status}
        className="btn-primary btn-m"
      >
        Activate Learning Mode
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
