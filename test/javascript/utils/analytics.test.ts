import {
  trackEvent,
  checkoutEventProperties,
  isPaymentTrigger,
} from '@/utils/analytics'

const originalFetch = global.fetch

afterEach(() => {
  global.fetch = originalFetch
})

test('posts the event to the events endpoint', () => {
  const fetchMock = jest.fn().mockResolvedValue({})
  global.fetch = fetchMock

  trackEvent('payment_prompt_shown', { trigger: 'beg_modal' })

  expect(fetchMock).toHaveBeenCalledWith('/api/v2/events', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      event: 'payment_prompt_shown',
      properties: { trigger: 'beg_modal' },
    }),
    credentials: 'same-origin',
    keepalive: true,
  })
})

test('swallows a rejected request', async () => {
  global.fetch = jest.fn().mockRejectedValue(new Error('offline'))

  expect(() => trackEvent('assistant_limit_reached')).not.toThrow()
  await Promise.resolve()
})

test('swallows an error thrown by fetch itself', () => {
  global.fetch = jest.fn(() => {
    throw new Error('bad request')
  })

  expect(() => trackEvent('assistant_limit_reached')).not.toThrow()
})

test('builds the checkout properties', () => {
  expect(
    checkoutEventProperties({
      trigger: 'donations_page',
      paymentType: 'subscription',
      amountInCents: 1600,
    })
  ).toEqual({
    trigger: 'donations_page',
    payment_type: 'subscription',
    amount_in_cents: 1600,
  })
})

test('leaves out a missing trigger', () => {
  expect(
    checkoutEventProperties({ paymentType: 'payment', amountInCents: 3200 })
  ).toEqual({ payment_type: 'payment', amount_in_cents: 3200 })
})

test('recognises the known triggers', () => {
  expect(isPaymentTrigger('assistant_upsell_modal')).toBe(true)
  expect(isPaymentTrigger('somewhere')).toBe(false)
  expect(isPaymentTrigger(undefined)).toBe(false)
})
