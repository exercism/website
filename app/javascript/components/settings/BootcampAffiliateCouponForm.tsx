import React, { useState, useCallback } from 'react'
import { fetchJSON } from '@/utils/fetch-json'
import CopyToClipboardButton from '../common/CopyToClipboardButton'

type Links = {
  bootcampAffiliateCouponCode: string
  insidersPath: string
}

export default function BootcampAffiliateCouponForm({
  context,
  insidersStatus,
  bootcampAffiliateCouponCode,
  links,
}: {
  context: 'settings' | 'bootcamp'
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

  switch (context) {
    case 'settings':
      return (
        <div>
          <h2 className="mb-8!">Bootcamp Affiliate Coupon</h2>
          <InfoMessage
            isInsider={isInsider}
            insidersStatus={insidersStatus}
            insidersPath={links.insidersPath}
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
              {loading
                ? 'Generating code...'
                : 'Generate your Affiliate Discount code'}
            </button>
          )}
          <ErrorMessage error={error} />
        </div>
      )
    case 'bootcamp': {
      return (
        <div>
          <h2 className="mb-2">Affiliate Coupon</h2>
          <p className="mb-8">
            To help us get more people benefitting from the Bootcamp, we're
            giving you an Affiliate Code to share. Anyone using the code gets
            20% off the Bootcamp, and we give you 20% of what they pay.
          </p>
          <p className="mb-12">
            Please share this Affiliate Code with your friends &amp; colleagues,
            and on social media.{' '}
          </p>

          {couponCode ? (
            <CopyToClipboardButton textToCopy={couponCode} />
          ) : (
            <button
              id="generate-affiliate-coupon-code-button"
              onClick={generateCouponCode}
              disabled={loading}
              type="button"
              className="btn btn-primary"
            >
              {loading
                ? 'Generating code...'
                : 'Generate your Affiliate Discount code'}
            </button>
          )}
          <ErrorMessage error={error} />
        </div>
      )
    }
  }
}

export function InfoMessage({
  insidersStatus,
  insidersPath,
  isInsider,
}: {
  insidersStatus: string
  insidersPath: string
  isInsider: boolean
}): JSX.Element {
  if (isInsider) {
    return (
      <>
        <p className="text-p-base mb-12">
          To thank you for being an Insider and to help increase the amount of
          people signing up to Exercism's {/* LINK NEEDS UPDATING */}
          <a href="https://exercism.org/bootcamp?utm_source=exercism&utm_medium=affiliate_settings">
            Learn to Code Bootcamp
          </a>
          , we are giving all Insiders an{' '}
          <strong className="font-semibold">Discount Affiliate code</strong>.
        </p>
        <p className="text-p-base mb-12">
          This code gives a 20% discount for the bootcamp (on top of any
          geographical discount). And for everyone that signs up,{' '}
          <strong>we'll give you 20%</strong> of whatever they pay.
        </p>
        <p className="text-p-base mb-16">
          Please help us spread the word. Send this code to your friends, post
          it on social media. Maybe even print it out on postcards and put it
          through your neighbours doors?
        </p>
      </>
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
          Exercism Insiders can access 20% off Exercism's{' '}
          {/* LINK NEEDS UPDATING */}
          <a href="https://exercism.org/bootcamp?utm_source=exercism&utm_medium=affiliate_settings">
            Learn to Code Bootcamp
          </a>
          , and receive 20% of all sales when someone uses their voucher code.
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
