import { renderHook, act } from '@testing-library/react'
import { useStripe, useElements } from '@stripe/react-stripe-js'
import { useStripeForm } from '@/components/donations/stripe-form/useStripeForm'

jest.mock('@stripe/react-stripe-js', () => ({
  useStripe: jest.fn(),
  useElements: jest.fn(),
  CardElement: 'CardElement',
}))

test('resets processing when Stripe rejects the card details', async () => {
  const fetchSpy = jest.spyOn(global, 'fetch')
  ;(useStripe as jest.Mock).mockReturnValue({})
  ;(useElements as jest.Mock).mockReturnValue({
    submit: jest
      .fn()
      .mockResolvedValue({
        error: { message: 'Your card number is invalid.' },
      }),
  })

  const { result } = renderHook(() =>
    useStripeForm({
      captchaRequired: false,
      paymentIntentType: 'payment',
      amount: { intValue: 1000 } as any,
      confirmParamsReturnUrl: '',
      onSuccess: jest.fn(),
    })
  )

  await act(async () => {
    await result.current.handlePaymentSubmit({
      preventDefault: jest.fn(),
    } as any)
  })

  expect(result.current.processing).toBe(false)
  expect(result.current.error).toBe('Your card number is invalid.')
  expect(fetchSpy).not.toHaveBeenCalled()
})
