import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { redirectTo } from '@/utils/redirect-to'
import { GraphicalIcon } from '@/components/common'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/dropdowns/track-menu')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<UserTrack | undefined>({
    mutationFn: async () => {
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
    onSuccess: (track) => {
      if (!track) {
        return
      }

      redirectTo(track.links.self)
    },
  })

  return (
    <Modal className="m-activate-learning-mode" onClose={onClose} {...props}>
      <GraphicalIcon icon="learning-mode" category="graphics" />
      <h2>{t('activateLearningModeModal.activateLearningMode')}</h2>
      <p>{t('activateLearningModeModal.paragraph1')}</p>
      <div className="warning">{t('activateLearningModeModal.warning')}</div>

      <FormButton
        onClick={() => mutation()}
        status={status}
        className="btn-primary btn-m"
      >
        {t('activateLearningModeModal.activateLearningModeButton')}
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
