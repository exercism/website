import React, { useCallback, useEffect, useState } from 'react'
import { useMutation } from 'react-query'
import currency from 'currency.js'
import { sendRequest, typecheck, redirectTo } from '@/utils'
import { GraphicalIcon } from '../common'
import { ExercismStripeElements } from '../donations/ExercismStripeElements'
import { StripeForm } from '../donations/StripeForm'
import { ModalHeader, ModalFooter } from '../premium/PriceOption'
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
  links: { insidersPath: string }
}

type Response = {
  handle: string
  insidersStatus: InsidersStatus
}

export default function Status({
  data,
}: {
  data: InsidersStatusData
}): JSX.Element {
  const { status, insidersStatusRequest, activateInsiderLink } = data
  const [insidersStatus, setInsidersStatus] = useState(status)
  const [stripeModalOpen, setStripeModalOpen] = useState(false)

  const handleSuccess = useCallback(() => {
    redirectTo(data.links.insidersPath)
  }, [data.links.insidersPath])

  const handleModalOpen = useCallback(() => {
    setStripeModalOpen(true)
  }, [])

  const [mutation] = useMutation<Response>(
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

  const [activateInsider] = useMutation(
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

  const [amount, setAmount] = useState(currency(16))
  const [showError, setShowError] = useState(false)

  const handleAmountInputChange = useCallback((amount: currency) => {
    setAmount(amount)
  }, [])

  const handleShowError = useCallback(() => {
    if (amount.value < 10) {
      setShowError(true)
    } else setShowError(false)
  }, [amount.value])

  return (
    <div className="flex flex-col items-start">
      <div
        className={`c-insiders-prompt mb-36 ${STATUS_DATA[insidersStatus].css}`}
      >
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
        <button
          onClick={handleModalOpen}
          className="flex get-insiders-link grow"
        >
          <span>Donate to Exercism to access Insiders</span>
          <GraphicalIcon icon="arrow-right" />
        </button>
      )}

      <Modal
        className="m-premium-stripe-form"
        onClose={() => setStripeModalOpen(false)}
        open={stripeModalOpen}
        theme="dark"
        ReactModalClassName="max-w-[570px]"
      >
        <ModalHeader period={'lifetime'} />
        <hr className="mb-32 border-borderColor5 -mx-48" />

        <div className="mb-12">
          <h3 className="mb-8 text-h6">
            Choose your monthly donation (minimum $10):
          </h3>
          <CustomAmountInput
            onChange={handleAmountInputChange}
            onBlur={handleShowError}
            placeholder="Specify amount"
            value={amount || currency(0)}
            selected={true}
            min="10"
          />
          {showError && (
            <div className="c-alert--danger mt-12">
              Please note: The minimum donation amount is $10. Thank you for
              your generous support!
            </div>
          )}
        </div>
        <ExercismStripeElements>
          <StripeForm
            captchaRequired={data.captchaRequired}
            userSignedIn={data.userSignedIn}
            recaptchaSiteKey={data.recaptchaSiteKey}
            paymentIntentType="payment"
            amount={isNaN(amount.value) ? currency(0) : amount}
            onSuccess={handleSuccess}
            submitButtonDisabled={amount.value < 10}
          />
        </ExercismStripeElements>
        <ModalFooter period={'lifetime'} />
      </Modal>
    </div>
  )
}
