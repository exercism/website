import React, { useState, useCallback } from 'react'
import { fetchJSON } from '@/utils/fetch-json'
import CopyToClipboardButton from '../common/CopyToClipboardButton'

type Links = {
  bootcampFreeCouponCode: string
}

export default function BootcampFreeCouponForm({
  bootcampFreeCouponCode,
  links,
}: {
  bootcampFreeCouponCode: string
  links: Links
}): JSX.Element {
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
      <h2>Bootcamp Free coupon</h2>
      <p className="text-p-base mb-16">
        {couponCode
          ? 'You can use this coupon once to get access to the bootcamp for free.'
          : "As a lifetime insider you're eligible for a free bootcamp coupon."}
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
