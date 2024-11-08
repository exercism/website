import React, { useState, useCallback } from 'react'
import { fetchJSON } from '@/utils/fetch-json'
import CopyToClipboardButton from '../common/CopyToClipboardButton'

type Links = {
  bootcampAffiliateCouponCode: string
  insidersPath: string
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export default function BootcampAffiliateForm({
  insidersStatus,
  bootcampAffiliateCouponCode,
  links,
}: {
  insidersStatus: string
  bootcampAffiliateCouponCode: string
  links: Links
}): JSX.Element {
  const [couponCode, setCouponCode] = useState(bootcampAffiliateCouponCode)

  const generateCouponCode = useCallback(async () => {
    return fetchJSON<{ coupon_code: string }>(
      links.bootcampAffiliateCouponCode,
      {
        method: 'POST',
        body: null,
      }
    ).then((data) => {
      setCouponCode(data.coupon_code)
    })
  }, [])

  const isInsider =
    insidersStatus == 'active' || insidersStatus == 'active_lifetime'

  return (
    <div>
      <h2>Bootcamp Affiliate</h2>
      <InfoMessage
        isInsider={isInsider}
        insidersStatus={insidersStatus}
        insidersPath={links.insidersPath}
      />

      {bootcampAffiliateCouponCode ? (
        <CopyToClipboardButton textToCopy={'hello'} />
      ) : (
        <button disabled={!isInsider} type="button" className="btn btn-primary">
          Click to generate code
        </button>
      )}
    </div>
  )
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
      <p className="text-p-base mb-16">
        You've not yet generated your affiliate code.
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
