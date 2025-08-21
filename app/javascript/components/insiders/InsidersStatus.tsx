// i18n-key-prefix: insidersStatus
// i18n-namespace: components/insiders
import React, { useCallback, useEffect, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import currency from 'currency.js'
import { typecheck, redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { StripeForm } from '../donations/StripeForm'
import { Modal } from '../modals'
import { CustomAmountInput } from '../donations/donation-form/CustomAmountInput'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const STATUS_DATA = {
  eligible: {
    textKey: 'insidersStatus.eligibleText',
    css: '--already-insider',
  },

  ineligible: {
    textKey: 'insidersStatus.ineligibleText',
    css: '--ineligible',
  },

  eligible_lifetime: {
    textKey: 'insidersStatus.eligibleLifetimeText',
    css: '--already-insider',
  },

  unset: {
    textKey: 'insidersStatus.unsetText',
    css: '--unset',
  },
}

type InsidersStatus = 'eligible' | 'eligible_lifetime' | 'unset' | 'ineligible'
export type InsidersStatusData = {
  status: InsidersStatus
  insidersStatusRequest: string
  activateInsiderLink: string
  userSignedIn: boolean
  captchaRequired: boolean
  recaptchaSiteKey: string
  links: {
    insiders: string
    paymentPending: string
  }
}

type Response = {
  handle: string
  insidersStatus: InsidersStatus
}

export default function Status({
  activateInsiderLink,
  captchaRequired,
  insidersStatusRequest,
  links,
  recaptchaSiteKey,
  status,
  userSignedIn,
}: InsidersStatusData): JSX.Element {
  const { t } = useAppTranslation('components/insiders')
  const [insidersStatus, setInsidersStatus] = useState(status)
  const [stripeModalOpen, setStripeModalOpen] = useState(false)

  const handleSuccess = useCallback(() => {
    redirectTo(links.insiders)
  }, [links.insiders])

  const handleModalOpen = useCallback(() => {
    setStripeModalOpen(true)
  }, [])

  const { mutate: mutation } = useMutation<Response>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: insidersStatusRequest,
        method: 'GET',
        body: null,
      })

      return fetch.then((json) => typecheck<Response>(json, 'user'))
    },
    onSuccess: (elem) => setInsidersStatus(elem.insidersStatus),
  })

  const { mutate: activateInsider } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: activateInsiderLink,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: (res) => redirectTo(res.links.redirectUrl),
  })

  useEffect(() => {
    if (insidersStatus === 'unset') {
      mutation()
    }
  }, [insidersStatus, mutation])

  const eligible =
    insidersStatus === 'eligible' || insidersStatus === 'eligible_lifetime'

  const [amount, setAmount] = useState<currency>(currency(10))
  const [showError, setShowError] = useState(false)
  const invalidAmount = amount.value < 10 || isNaN(amount.value)
  const handleShowError = useCallback(() => {
    if (invalidAmount) {
      setShowError(true)
    } else setShowError(false)
  }, [invalidAmount])

  const handleAmountInputChange = useCallback((amount: currency) => {
    setAmount(amount)
  }, [])

  return (
    <div className="flex flex-col items-start">
      <div className={`c-insiders-prompt ${STATUS_DATA[insidersStatus].css}`}>
        {t(STATUS_DATA[insidersStatus].textKey)}
      </div>

      {eligible ? (
        <button
          className="flex get-insiders-link grow"
          onClick={() => activateInsider()}
        >
          <span>{t('insidersStatus.getAccessToInsiders')}</span>
          <GraphicalIcon icon="arrow-right" />
        </button>
      ) : (
        <>
          <button
            onClick={handleModalOpen}
            className="flex get-insiders-link grow w-fill lg:w-auto"
          >
            <span>{t('insidersStatus.donateToAccessInsiders')}</span>
            <GraphicalIcon icon="arrow-right" />
          </button>
        </>
      )}

      <Modal
        onClose={() => setStripeModalOpen(false)}
        open={stripeModalOpen}
        theme="dark"
        cover={true}
        closeButton={true}
        ReactModalClassName="max-w-[660px]"
      >
        <div className="--modal-content-inner">
          <ModalHeader />
          <hr className="mb-20 border-borderColor5" />

          <div className="mb-24">
            <h3 className="mb-8 text-h6 font-semibold">
              {t('insidersStatus.chooseMonthlyDonation')}
            </h3>
            <CustomAmountInput
              onChange={handleAmountInputChange}
              onBlur={handleShowError}
              placeholder={t('insidersStatus.specifyAmount')}
              value={amount}
              selected={true}
              min="10"
              className="max-w-[150px]"
            />
            {showError && (
              <div className="c-alert mt-12 text-p-base flex flex-row items-center gap-8">
                <GraphicalIcon
                  icon="question-circle"
                  className="h-[24px] w-[24px] filter-warning"
                />
                {t('insidersStatus.minimumDonationAmount')}
              </div>
            )}
          </div>
          <h3 className="mb-16 text-h6 font-semibold">
            {t('insidersStatus.choosePaymentMethod')}
          </h3>
          <ExercismStripeElements
            mode="subscription"
            amount={
              isNaN(amount.intValue) ? currency(0).intValue : amount.intValue
            }
          >
            <StripeForm
              confirmParamsReturnUrl={links.paymentPending}
              captchaRequired={captchaRequired}
              userSignedIn={userSignedIn}
              recaptchaSiteKey={recaptchaSiteKey}
              amount={isNaN(amount.value) ? currency(0) : amount}
              onSuccess={handleSuccess}
              submitButtonDisabled={invalidAmount}
              paymentIntentType="subscription"
            />
          </ExercismStripeElements>
          <ModalFooter />
        </div>
      </Modal>
    </div>
  )
}

function ModalHeader(): JSX.Element {
  const { t } = useAppTranslation('components/insiders')
  return (
    <>
      <div className="flex flex-row items-center gap-32 mb-12">
        <div>
          <h2 className="text-h2 mb-2 !text-white">
            {t('insidersStatus.thankYou')}
          </h2>
          <p className="text-p-large !text-white">
            {t('insidersStatus.thankYouForSupport')}
          </p>
        </div>
        <GraphicalIcon
          icon="confetti-without-background"
          category="graphics"
          className="w-[96px] h-[96px]"
        />
      </div>
      <p className="text-p-base !text-white mb-20">
        {t('insidersStatus.setUpMonthlyDonation')}
      </p>
    </>
  )
}

function ModalFooter(): JSX.Element {
  const { t } = useAppTranslation('components/insiders')
  return (
    <p className="text-p-small mt-20">
      {t('insidersStatus.donationsImprovePlatform')}
    </p>
  )
}
