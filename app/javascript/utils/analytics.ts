import type { PaymentIntentType } from '@/components/donations/stripe-form/useStripeForm'

/**
 * The places in the UI where someone can be asked to pay. Every checkout
 * funnel event records one of these as its trigger. The server drops values
 * it doesn't know, so add any new trigger to Analytics::TRIGGERS in
 * app/models/analytics.rb too.
 */
const PAYMENT_TRIGGERS = [
  'donations_page',
  'footer_form',
  'beg_modal',
  'mentoring_donation_step',
  'insiders_page',
  'insiders_join_page',
  'assistant_upsell_modal',
] as const

export type PaymentTrigger = (typeof PAYMENT_TRIGGERS)[number]

export type AnalyticsEvent =
  | 'payment_prompt_shown'
  | 'assistant_limit_reached'
  | 'checkout_submitted'
  | 'checkout_failed'
  | 'checkout_closed'

const EVENTS_ENDPOINT = '/api/v2/events'

/**
 * Sends an analytics event to the server, which passes it on to PostHog.
 * Analytics must never break the site, so this never throws and its errors
 * are swallowed. `keepalive` lets the request finish if the page unloads,
 * which matters for checkout_closed.
 *
 * Don't await it. It returns nothing on purpose.
 */
export function trackEvent(
  event: AnalyticsEvent,
  properties: Record<string, unknown> = {}
): void {
  if (typeof window === 'undefined') return

  try {
    void fetch(EVENTS_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ event, properties }),
      credentials: 'same-origin',
      keepalive: true,
    }).catch(() => {})
  } catch {
    // fetch can throw synchronously, for example on a malformed request.
  }
}

/**
 * The properties shared by every checkout funnel event. A missing trigger
 * is left out, because PostHog would show it as a literal "null".
 */
export function checkoutEventProperties({
  trigger,
  paymentType,
  amountInCents,
}: {
  trigger?: PaymentTrigger
  paymentType: PaymentIntentType
  amountInCents: number
}): Record<string, unknown> {
  return {
    ...(trigger ? { trigger } : {}),
    payment_type: paymentType,
    amount_in_cents: amountInCents,
  }
}

export function isPaymentTrigger(value: unknown): value is PaymentTrigger {
  return PAYMENT_TRIGGERS.includes(value as PaymentTrigger)
}
