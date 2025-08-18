import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { redirectTo } from '@/utils/redirect-to'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { GraphicalIcon } from '@/components/common'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { FormButton } from '@/components/common/FormButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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

      redirectTo(redirectToOnSuccessUrl || track.links.self)
    },
  })

  return (
    <Modal className="m-activate-practice-mode" onClose={onClose} {...props}>
      <GraphicalIcon icon="practice-mode" category="graphics" />
      <h2>{t('activatePracticeModeModal.disableLearningMode')}</h2>
      <p>{t('activatePracticeModeModal.paragraph1')}</p>
      <div className="warning">{t('activatePracticeModeModal.warning')}</div>

      <FormButton
        onClick={() => mutation()}
        status={status}
        className="btn-primary btn-m"
      >
        {t('activatePracticeModeModal.disableLearningModeButton')}
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
