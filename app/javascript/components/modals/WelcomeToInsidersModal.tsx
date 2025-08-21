// i18n-key-prefix: welcomeToInsidersModal
// i18n-namespace: components/modals/WelcomeToInsidersModal.tsx
import React, { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from './Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export default function WelcomeToInsidersModal({
  endpoint,
  ...props
}: Omit<ModalProps, 'className' | 'open' | 'onClose'> & {
  endpoint: string
}): JSX.Element {
  const [open, setOpen] = useState(true)
  const { t } = useAppTranslation(
    'components/modals/WelcomeToInsidersModal.tsx'
  )
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: () => {
      setOpen(false)
    },
  })

  const handleClick = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <Modal
      cover={true}
      open={open}
      {...props}
      onClose={() => null}
      theme="dark"
      className="m-welcome"
    >
      <div className="lhs">
        <header>
          <h1>{t('welcomeToInsidersModal.title')}</h1>

          <p className="">{t('welcomeToInsidersModal.accessToFeatures')}</p>
        </header>

        <h2>{t('welcomeToInsidersModal.thanksForBeingPartOfOurStory')}</h2>
        <p className="mb-12">
          {t('welcomeToInsidersModal.exercismReliesOnPeople')}
        </p>

        <p className="mb-12">
          {t('welcomeToInsidersModal.weHopeInsidersIsFun')}
        </p>

        <FormButton
          status={status}
          className="btn-primary btn-l"
          type="button"
          onClick={handleClick}
        >
          {t('welcomeToInsidersModal.greatLetsGo')}
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </div>
      <div className="rhs">
        <h2 className="text-h4 mb-12">
          {t('welcomeToInsidersModal.startWithOurWelcomeVideo')}
        </h2>
        <div
          className="video relative rounded-8 overflow-hidden !mb-24"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://www.youtube-nocookie.com/embed/zomfphsDQrs"
            title="Welcome to Exercism Insiders!"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <h2 className="text-h4 mb-4">
          {t('welcomeToInsidersModal.whatShouldIDoNext')}
        </h2>
        <p className="text-p-base mb-8">
          {t('welcomeToInsidersModal.exploreDarkMode')}
        </p>
      </div>
    </Modal>
  )
}
