import React, { useState } from 'react'
import { Modal, ModalProps } from '../../modals/Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { FormButton, GraphicalIcon } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { redirectTo } from '../../../utils/redirect-to'

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

        redirectTo(track.links.self)
      },
    }
  )

  return (
    <Modal className="m-activate-practice-mode" onClose={onClose} {...props}>
      <GraphicalIcon icon="practice-mode" category="graphics" />
      <h2>Activate Practice Mode</h2>
      <p>
        Activating Practice Mode will unlock all the Practice Exercises on this
        track, but will disable Concepts and Learning Exercises.
      </p>
      <div className="warning">
        You can switch in and out of Practice Mode at any time.
      </div>

      <FormButton
        onClick={() => mutation()}
        status={status}
        className="btn-primary btn-m"
      >
        Activate Practice Mode
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
