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

const STATUS_DATA = {
  eligible: {
    text: "You're currently eligible for Insiders. Thank you for being part of Exercism. We're excited to continue with you on our journey!",
    css: '--already-insider',
  },

  ineligible: {
    text: 'Set up a recurring monthly donation of $10 or more to access Insiders',
    css: '--ineligible',
  },

  eligible_lifetime: {
    text: "We've given you lifetime access to Insiders. Thank you for being part of Exercism. We're excited to continue with you on our journey!",
    css: '--already-insider',
  },

  unset: {
    text: "We're currently calculating your Insiders status. This box will update once we've finished.",
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
  const [insidersStatus, setInsidersStatus] = useState(status)
  const [stripeModalOpen, setStripeModalOpen] = useState(false)

  const handleSuccess = useCallback(() => {
    redirectTo(links.insiders)
  }, [links.insiders])

  const handleModalOpen = useCallback(() => {
    setStripeModalOpen(true)
  }, [])

  const { mutate: mutation } = useMutation<Response>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: insidersStatusRequest,
        method: 'GET',
        body: null,
      })

      return fetch.then((json) => typecheck<Response>(json, 'user'))
    },
    {
      onSuccess: (elem) => setInsidersStatus(elem.insidersStatus),
    }
  )

  const { mutate: activateInsider } = useMutation(
    async () => {
      const { fetch } = sendRequest({
        endpoint: activateInsiderLink,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: (res) => redirectTo(res.links.redirectUrl),
    }
  )

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
        {STATUS_DATA[insidersStatus].text}
      </div>

      {eligible ? (
        <button
          className="flex get-insiders-link grow"
          onClick={() => activateInsider()}
        >
          <span>Get access to Insiders</span>
          <GraphicalIcon icon="arrow-right" />
        </button>
      ) : (
        <>
          <button
            onClick={handleModalOpen}
            className="flex get-insiders-link grow mb-12 w-fill lg:w-auto"
          >
            <span>Donate to Exercism to access Insiders</span>
            <GraphicalIcon icon="arrow-right" />
          </button>

          <p className="text-p-base italic">
            Exercism is an independent, registered not-for-profit organisation
            (UK #11733062) with a tiny team. All donations are used to run and
            improve the platform.
          </p>
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
              1. Choose your monthly donation:
            </h3>
            <CustomAmountInput
              onChange={handleAmountInputChange}
              onBlur={handleShowError}
              placeholder="Specify amount"
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
                Please note: The minimum donation amount for Insiders Access is
                $10.00. Thank you for your kind support!
              </div>
            )}
          </div>
          <h3 className="mb-16 text-h6 font-semibold">
            2. Choose your payment method:
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
  return (
    <>
      <div className="flex flex-row items-center gap-32 mb-12">
        <div>
          <h2 className="text-h2 mb-2 !text-white">Thank you!</h2>
          <p className="text-p-large !text-white">
            Thank you so much for supporting Exercism. It means the world to us!
            💜
          </p>
        </div>
        <GraphicalIcon
          icon="confetti-without-background"
          category="graphics"
          className="w-[96px] h-[96px]"
        />
      </div>
      <p className="text-p-base !text-white mb-20">
        Please use the form below to set up your monthly donation. You can amend
        or cancel your donation at any time in your settings page.
      </p>
    </>
  )
}

function ModalFooter(): JSX.Element {
  return (
    <p className="text-p-small mt-20">
      Exercism is an independent not-for-profit organisation. All donations are
      used to run and improve the platform. All payments are securely handled by
      Stripe.
    </p>
  )
}
