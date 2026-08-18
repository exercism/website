import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { GraphicalIcon } from '@/components/common'
import { Modal } from '@/components/modals'
import { ExercismStripeElements } from '@/components/donations/ExercismStripeElements'
import { StripeForm } from '@/components/donations/StripeForm'
import type { InsidersUpsellConfig } from './types'

// Insiders is a donation-funded tier, so joining from the editor runs exactly
// the same Stripe subscription flow as the /insiders page. The only difference
// is that the amount is fixed here rather than user-chosen.
const MONTHLY_AMOUNT = currency(10)

export function InsidersUpsellModal({
  config,
  open,
  onClose,
}: {
  config: InsidersUpsellConfig
  open: boolean
  onClose: () => void
}): JSX.Element {
  const [succeeded, setSucceeded] = useState(false)

  const handleSuccess = useCallback(() => setSucceeded(true), [])

  // StripeForm awaits the `payment_intents/:id/succeeded` call before invoking
  // onSuccess, and that request activates Insiders synchronously
  // (User::InsidersStatus::UpdateForPayment). So by the time we get here the
  // user really is an Insider — but this page was server-rendered for a
  // non-Insider (the editor's `insider` prop, the chat's `allowed` flag, the
  // nav flair). Reloading is the simplest way to make the whole page agree.
  // The editor's files are safe: useSaveFiles persists them to localStorage
  // every 500ms and restores them on mount.
  const reload = useCallback(() => window.location.reload(), [])

  return (
    <Modal
      onClose={succeeded ? reload : onClose}
      open={open}
      theme="light"
      cover={true}
      className="m-assistant-chat-upsell"
      closeButton={true}
      ReactModalClassName="max-w-[660px]"
    >
      <div className="--modal-content-inner">
        {succeeded ? (
          <SuccessContent onContinue={reload} />
        ) : (
          <PaymentContent config={config} onSuccess={handleSuccess} />
        )}
      </div>
    </Modal>
  )
}

function PaymentContent({
  config,
  onSuccess,
}: {
  config: InsidersUpsellConfig
  onSuccess: () => void
}): JSX.Element {
  return (
    <>
      <div className="flex flex-row items-center gap-32 mb-12">
        <div>
          <h2 className="text-h2 mb-2">Unlock your AI Assistant</h2>
          <p className="text-p-large">
            Become an Insider for unlimited conversations on every exercise.
          </p>
        </div>
        <GraphicalIcon
          icon="confetti-without-background"
          category="graphics"
          className="w-[96px] h-[96px]"
        />
      </div>
      <p className="text-p-base mb-20">
        Exercism is funded by donations. Your{' '}
        <strong>{MONTHLY_AMOUNT.format()}</strong> a month keeps Exercism free
        for everyone, and unlocks the AI Assistant, dark mode, an ad-free
        experience and more.
      </p>

      <hr className="mb-20 border-borderColor5" />

      <ExercismStripeElements
        mode="subscription"
        amount={MONTHLY_AMOUNT.intValue}
      >
        <StripeForm
          confirmParamsReturnUrl={config.links.paymentPending}
          captchaRequired={config.captchaRequired}
          userSignedIn={config.userSignedIn}
          recaptchaSiteKey={config.recaptchaSiteKey}
          amount={MONTHLY_AMOUNT}
          onSuccess={onSuccess}
          paymentIntentType="subscription"
        />
      </ExercismStripeElements>

      <p className="text-p-small mt-20">
        You can change or cancel your donation at any time from your settings.
      </p>
    </>
  )
}

function SuccessContent({
  onContinue,
}: {
  onContinue: () => void
}): JSX.Element {
  return (
    <div className="text-center">
      <GraphicalIcon
        icon="confetti-without-background"
        category="graphics"
        className="w-[96px] h-[96px] mx-auto mb-16"
      />
      <h2 className="text-h2 mb-8">You&apos;re an Insider! 💙</h2>
      <p className="text-p-large mb-16">
        Thank you for supporting Exercism. Your AI Assistant is unlocked on
        every exercise, along with dark mode, an ad-free experience, and
        everything else Insiders unlocks.
      </p>
      <p className="text-p-base mb-24">
        We&apos;ll pop a receipt in your inbox shortly.
      </p>
      <button
        type="button"
        className="btn-l btn-primary w-100"
        onClick={onContinue}
      >
        Start working with the Assistant
      </button>
    </div>
  )
}
