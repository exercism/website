import React, { useContext } from 'react'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { WelcomeModalContext } from './WelcomeModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to dismiss modal')

export function SeniorView() {
  const { t } = useAppTranslation('components/modals/welcome-modal')
  const { numTracks, patchCloseModal } = useContext(WelcomeModalContext)

  return (
    <>
      <div className="lhs">
        <header>
          <h1>{t('welcomeModal.helloFellowDeveloper')}</h1>

          <p className="">
            {t('welcomeModal.exercismDeepenSkills', { numTracks })}
          </p>
        </header>

        <h2>{t('welcomeModal.thanksForJoining')}</h2>
        <p className="mb-12">{t('welcomeModal.madeByThousands')}</p>

        <p className="mb-12">{t('welcomeModal.watchWelcomeVideo')}</p>

        <FormButton
          status={patchCloseModal.status}
          className="btn-primary btn-l"
          type="button"
          onClick={patchCloseModal.mutate}
        >
          {t('welcomeModal.gotItCloseModal')}
        </FormButton>
        <ErrorBoundary resetKeys={[patchCloseModal.status]}>
          <ErrorMessage
            error={patchCloseModal.error}
            defaultError={DEFAULT_ERROR}
          />
        </ErrorBoundary>
      </div>
      <div className="rhs">
        <h2 className="text-h4 mb-12">
          {t('welcomeModal.startWithWelcomeVideo')}
        </h2>
        <div
          className="video relative rounded-8 overflow-hidden !mb-24"
          style={{ padding: '56.25% 0 0 0', position: 'relative' }}
        >
          <iframe
            src="https://www.youtube-nocookie.com/embed/8rmbTWAncb8"
            title="Introducing the 'Community' tab"
            frameBorder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
          />
        </div>
        <h2 className="text-h4 mb-4">{t('welcomeModal.whereCanIJoin')}</h2>
        <p className="text-p-base mb-8">
          {t('welcomeModal.discoveredExercism')}
        </p>
      </div>
    </>
  )
}
