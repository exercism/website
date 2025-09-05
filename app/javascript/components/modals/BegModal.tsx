// i18n-key-prefix: begModal
// i18n-namespace: components/modals/BegModal.tsx
import React, { lazy, Suspense, useCallback, useState } from 'react'
import currency from 'currency.js'
import { PaymentIntentType } from '@/components/donations/stripe-form/useStripeForm'
import { Request } from '@/hooks/request-query'
import { StripeFormLinks } from '@/components/donations/Form'
import { Modal } from '.'
import SuccessModal from '../donations/SuccessModal'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'
const Form = lazy(() => import('@/components/donations/Form'))

export default function ({
  previousDonor,
  links,
  request,
}: {
  previousDonor: boolean
  links: StripeFormLinks & { hideIntroducer: string }
  request: Request
}): JSX.Element {
  const [isModalOpen, setIsModalOpen] = useState(true)
  const [isSuccessModalOpen, setIsSuccessModalOpen] = useState(false)
  const [paymentAmount, setPaymentAmount] = useState<currency | null>(null)
  const { t } = useAppTranslation()

  const handleSuccess = useCallback(
    (_type: PaymentIntentType, amount: currency) => {
      setIsModalOpen(false)
      setPaymentAmount(amount)
      setIsSuccessModalOpen(true)
    },
    [setIsModalOpen, setPaymentAmount, setIsSuccessModalOpen]
  )

  const {
    mutate: hideIntroducer,
    status,
    error,
  } = useMutation({
    mutationFn: () => {
      const { fetch } = sendRequest({
        endpoint: links.hideIntroducer,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: () => {
      setIsModalOpen(false)
    },
  })

  const handleContinueWithoutDonating = useCallback(() => {
    hideIntroducer()
  }, [hideIntroducer])

  const DEFAULT_ERROR = new Error('Unable to dismiss modal')

  return (
    <>
      <Modal
        style={{ content: { maxWidth: 'fit-content' } }}
        cover
        aria={{ modal: true, describedby: 'a11y-finish-mentor-discussion' }}
        className="m-finish-student-mentor-discussion"
        containerClassName="!p-48"
        ReactModalClassName="bg-unnamed15"
        shouldCloseOnOverlayClick={false}
        shouldCloseOnEsc={false}
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      >
        <div
          id="a11y-finish-mentor-discussion"
          className="flex lg:flex-row flex-col"
        >
          <div className="lg:mr-64 mr-0 lg:max-w-[700px] max-w-full">
            <h3 className="text-h4 mb-4 text-prominentLinkColor">
              {t('begModal.sorryToDisturb')}
            </h3>
            <h1 className="text-h1 mb-12">{t('begModal.weNeedYourHelp')}</h1>

            <div className="mb-20 pb-20 border-b-1 border-borderColor7">
              {previousDonor ? <PreviousDonorContent /> : <NonDonorContent />}
            </div>

            <h3 className="text-h4 mb-6">{t('begModal.cantAffordIt')}</h3>
            <p className="text-p-large mb-20">{t('begModal.shareExercism')}</p>

            <h3 className="text-h4 mb-6">{t('begModal.wantToKnowMore')}</h3>
            <p className="text-p-large mb-20">
              {t('begModal.explainsWhyWeNeedDonations')}
            </p>

            <div className="c-youtube-container mb-32">
              <iframe
                width="560"
                height="315"
                frameBorder="0"
                src="https://player.vimeo.com/video/855534271?h=97d3a4c8c2&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479&transparent=0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              />
              <script src="https://player.vimeo.com/api/player.js" />
            </div>
          </div>
          <div className="flex flex-col items-end bg-transparent">
            <div className="lg:w-[564px] w-100 shadow-lgZ1 rounded-8 mb-20">
              <Suspense fallback={<div className="c-loading-suspense" />}>
                <Form
                  request={request}
                  defaultAmount={{
                    payment: currency(16),
                    subscription: currency(16),
                  }}
                  userSignedIn={true}
                  captchaRequired={false}
                  links={links}
                  onSuccess={handleSuccess}
                />
              </Suspense>
            </div>

            <div className="lg:w-[564px] w-100 border-2 border-gradient bg-lightPurple py-12 px-24 rounded-8">
              <p className="text-gradient font-semibold leading-160 text-17">
                {t('begModal.fewerThan1Percent')}
              </p>
            </div>
          </div>
        </div>
        <div className="flex items-center lg:border-t-1 border-borderColor6 pt-20">
          <button
            onClick={handleContinueWithoutDonating}
            className="btn-enhanced btn-l !shadow-xsZ1v3 py-16 px-24"
          >
            {t('begModal.continueWithoutDonating')}
          </button>
          <ErrorBoundary resetKeys={[status]}>
            <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
          </ErrorBoundary>
        </div>
      </Modal>
      <SuccessModal
        open={isSuccessModalOpen}
        amount={paymentAmount}
        handleCloseModal={() => setIsSuccessModalOpen(false)}
      />
    </>
  )
}

export function PreviousDonorContent() {
  const { t } = useAppTranslation()
  return (
    <>
      <p className="text-p-large mb-12">
        {t('begModal.previousDonorContent.thankYou')}
      </p>
      <p className="text-p-large mb-12">
        <Trans
          i18nKey="begModal.previousDonorContent.hateToAskAgain"
          components={[<strong className="font-medium" />]}
        />
      </p>
      <p className="text-p-large">
        {t('begModal.previousDonorContent.monthlyDonationHelpful')}
      </p>
    </>
  )
}

export function NonDonorContent() {
  const { t } = useAppTranslation()
  return (
    <>
      <p className="text-p-large mb-12">
        {t('begModal.nonDonorContent.exercismReliesOnDonations')}
      </p>
      <p className="text-p-large mb-12">
        <Trans
          i18nKey="begModal.nonDonorContent.mostPeopleCantAfford"
          components={[<strong className="font-medium" />]}
        />
      </p>
      <p className="text-p-large">
        {t('begModal.nonDonorContent.only1Percent')}
      </p>
    </>
  )
}
