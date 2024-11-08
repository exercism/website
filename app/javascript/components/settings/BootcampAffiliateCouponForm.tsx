import React, { useState, useCallback } from 'react'
import { fetchJSON } from '@/utils/fetch-json'
import CopyToClipboardButton from '../common/CopyToClipboardButton'

type Links = {
  bootcampAffiliateCouponCode: string
  insidersPath: string
}

export default function BootcampAffiliateCouponForm({
  insidersStatus,
  bootcampAffiliateCouponCode,
  links,
}: {
  insidersStatus: string
  bootcampAffiliateCouponCode: string
  links: Links
}): JSX.Element {
  const [couponCode, setCouponCode] = useState(bootcampAffiliateCouponCode)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const generateCouponCode = useCallback(async () => {
    setLoading(true)
    try {
      const data = await fetchJSON<{ couponCode: string }>(
        links.bootcampAffiliateCouponCode,
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

  const isInsider =
    insidersStatus == 'active' || insidersStatus == 'active_lifetime'

  return (
    <div>
      <h2>Bootcamp Affiliate Coupon</h2>
      <InfoMessage
        isInsider={isInsider}
        insidersStatus={insidersStatus}
        insidersPath={links.insidersPath}
        couponCode={couponCode}
      />

      {couponCode ? (
        <CopyToClipboardButton textToCopy={couponCode} />
      ) : (
        <button
          id="generate-affiliate-coupon-code-button"
          onClick={generateCouponCode}
          disabled={!isInsider || loading}
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

export function InfoMessage({
  insidersStatus,
  insidersPath,
  isInsider,
  couponCode,
}: {
  insidersStatus: string
  insidersPath: string
  isInsider: boolean
  couponCode: string
}): JSX.Element {
  if (isInsider) {
    return (
      <p className="text-p-base mb-16">
        {couponCode
          ? 'You can save 20% on the bootcamp with this affiliate code.'
          : "You've not yet generated your affiliate code."}
      </p>
    )
  }

  switch (insidersStatus) {
    case 'eligible':
    case 'eligible_lifetime':
      return (
        <p className="text-p-base mb-16">
          You&apos;re eligible to join Insiders.{' '}
          <a href={insidersPath}>Get started here.</a>
        </p>
      )
    default:
      return (
        <p className="text-p-base mb-16">
          These are exclusive options for Exercism Insiders.&nbsp;
          <strong>
            <a className="text-prominentLinkColor" href={insidersPath}>
              Donate to Exercism
            </a>
          </strong>{' '}
          and become an Insider to access these benefits with Dark Mode, ChatGPT
          integration and more.
        </p>
      )
  }
}

function ErrorMessage({ error }: { error: string | null }) {
  if (!error) return null
  return (
    <div className="c-alert--danger text-15 font-body mt-10 normal-case py-8 px-16">
      {error}
    </div>
  )
}
