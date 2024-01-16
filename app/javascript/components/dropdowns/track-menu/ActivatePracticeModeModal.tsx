import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { redirectTo } from '@/utils/redirect-to'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { GraphicalIcon } from '@/components/common'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { FormButton } from '@/components/common/FormButton'

type UserTrack = {
  links: {
    self: string
  }
}

const DEFAULT_ERROR = new Error('Unable to switch to practice mode')

export const ActivatePracticeModeModal = ({
  endpoint,
  onClose,
  redirectToOnSuccessUrl,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  redirectToOnSuccessUrl?: string
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<UserTrack | undefined>(
    async () => {
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

        redirectTo(redirectToOnSuccessUrl || track.links.self)
      },
    }
  )

  return (
    <Modal className="m-activate-practice-mode" onClose={onClose} {...props}>
      <GraphicalIcon icon="practice-mode" category="graphics" />
      <h2>Disable Learning Mode</h2>
      <p>
        Disabling Learning Mode will unlock all the Practice Exercises on this
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
        Disable Learning Mode
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
