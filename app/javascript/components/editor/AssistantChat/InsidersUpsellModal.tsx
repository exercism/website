// i18n-key-prefix: insidersUpsellModal
// i18n-namespace: components/editor/AssistantChat
import React, { useCallback, useState } from 'react'
import currency from 'currency.js'
import { GraphicalIcon } from '@/components/common'
import { Modal } from '@/components/modals'
import { ExercismStripeElements } from '@/components/donations/ExercismStripeElements'
import { StripeForm } from '@/components/donations/StripeForm'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'
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
  const { t } = useAppTranslation('components/editor/AssistantChat')

  return (
    <>
      <div className="flex flex-row items-center gap-32 mb-12">
        <div>
          <h2 className="text-h2 mb-2">
            {t('insidersUpsellModal.unlockYourAiAssistant')}
          </h2>
          <p className="text-p-large">
            {t('insidersUpsellModal.becomeAnInsiderFor')}
          </p>
        </div>
        <GraphicalIcon
          icon="confetti-without-background"
          category="graphics"
          className="w-[96px] h-[96px]"
        />
      </div>
      <p className="text-p-base mb-20">
        <Trans
          ns="components/editor/AssistantChat"
          i18nKey="insidersUpsellModal.fundedByDonations"
          values={{ amount: MONTHLY_AMOUNT.format() }}
          components={{
            strong: <strong />,
          }}
        />
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
        {t('insidersUpsellModal.changeOrCancel')}
      </p>
    </>
  )
}

function SuccessContent({
  onContinue,
}: {
  onContinue: () => void
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/AssistantChat')

  return (
    <div className="text-center">
      <GraphicalIcon
        icon="confetti-without-background"
        category="graphics"
        className="w-[96px] h-[96px] mx-auto mb-16"
      />
      <h2 className="text-h2 mb-8">
        {t('insidersUpsellModal.youreAnInsider')}
      </h2>
      <p className="text-p-large mb-16">
        {t('insidersUpsellModal.thankYouForSupporting')}
      </p>
      <p className="text-p-base mb-24">
        {t('insidersUpsellModal.receiptInYourInbox')}
      </p>
      <button
        type="button"
        className="btn-l btn-primary w-100"
        onClick={onContinue}
      >
        {t('insidersUpsellModal.startWorkingWithTheAssistant')}
      </button>
    </div>
  )
}
