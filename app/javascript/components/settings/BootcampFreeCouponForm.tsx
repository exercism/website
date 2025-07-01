import React, { useState, useCallback } from 'react'
import { fetchJSON } from '@/utils/fetch-json'
import CopyToClipboardButton from '../common/CopyToClipboardButton'

type Links = {
  bootcampFreeCouponCode: string
}

export type BootcampFreeCouponFormProps = {
  bootcampFreeCouponCode: string
  links: Links
}

export default function BootcampFreeCouponForm({
  bootcampFreeCouponCode,
  links,
}: BootcampFreeCouponFormProps): JSX.Element {
  const [couponCode, setCouponCode] = useState(bootcampFreeCouponCode)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const generateCouponCode = useCallback(async () => {
    setLoading(true)
    try {
      const data = await fetchJSON<{ couponCode: string }>(
        links.bootcampFreeCouponCode,
        {
          method: 'POST',
          body: null,
        }
      )
      setCouponCode(data.couponCode)
      setError(null)
    } catch (err) {
      console.error('Error generating coupon code:', err)
      setError('Failed to generate coupon code. Please try again.')
    } finally {
      setLoading(false)
    }
  }, [links])

  return (
    <div>
      <h2 className="mb-8!">Free Seat on the Bootcamp</h2>
      <p className="text-p-base mb-12">
        As a lifetime insider you're eligible for a free seat on Exercism's{' '}
        <a href="https://exercism.org/bootcamp?utm_source=exercism&utm_medium=free_settings">
          Learn to Code Bootcamp
        </a>
        .
      </p>
      <p className="text-p-base mb-16">
        To claim your free seat, we're providing you with a discount code that
        you can use at the checkout for a 100% discount. You can use it for
        yourself, give it to a friend, offer it to a charity, post it on social
        media, or anything else you feel appropriate.
      </p>

      {couponCode ? (
        <CopyToClipboardButton textToCopy={couponCode} />
      ) : (
        <button
          onClick={generateCouponCode}
          disabled={loading}
          type="button"
          className="btn btn-primary"
        >
          {loading ? 'Generating code...' : 'Click to generate code'}
        </button>
      )}
      <ErrorMessage error={error} />
    </div>
  )
}

function ErrorMessage({ error }: { error: string | null }) {
  if (!error) return null
  return (
    <div className="c-alert--danger text-15 font-body mt-10 normal-case py-8 px-16">
      {error}
    </div>
  )
}
