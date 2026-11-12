import { useEffect } from 'react'
import { trackEvent, type PaymentTrigger } from '@/utils/analytics'

/**
 * Records payment_prompt_shown whenever a payment prompt becomes visible.
 * The server sends it at most once per user per trigger per day.
 */
export function useTrackPaymentPrompt(
  trigger: PaymentTrigger,
  visible = true
): void {
  useEffect(() => {
    if (!visible) return

    trackEvent('payment_prompt_shown', { trigger })
  }, [trigger, visible])
}
