// i18n-key-prefix: bootcampAffiliateCouponForm
// i18n-namespace: components/settings/BootcampAffiliateCouponForm.tsx
import React, { useState, useCallback } from 'react'
import { fetchJSON } from '@/utils/fetch-json'
import CopyToClipboardButton from '../common/CopyToClipboardButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation(
    'components/settings/BootcampAffiliateCouponForm.tsx'
  )
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
      setError(
        t(
          'bootcampAffiliateCouponForm.failedToGenerateCouponCodePleaseTryAgain'
        )
      )
    } finally {
      setLoading(false)
    }
  }, [links, t])

  const isInsider =
    insidersStatus == 'active' || insidersStatus == 'active_lifetime'

  switch (context) {
    case 'settings':
      return (
        <div>
          <h2 className="!mb-8">
            {t('bootcampAffiliateCouponForm.bootcampAffiliateCoupon')}
          </h2>
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
                ? t('bootcampAffiliateCouponForm.generatingCode')
                : t(
                    'bootcampAffiliateCouponForm.generateYourAffiliateDiscountCode'
                  )}
            </button>
          )}
          <ErrorMessage error={error} />
        </div>
      )
    case 'bootcamp': {
      return (
        <div>
          <h2 className="mb-2">
            {t('bootcampAffiliateCouponForm.affiliateCoupon')}
          </h2>
          <p className="mb-8">
            {t('bootcampAffiliateCouponForm.helpUsGetMorePeopleBenefitting')}
          </p>
          <p className="mb-12">
            {t('bootcampAffiliateCouponForm.pleaseShareAffiliateCode')}{' '}
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
                ? t('bootcampAffiliateCouponForm.generatingCode')
                : t(
                    'bootcampAffiliateCouponForm.generateYourAffiliateDiscountCode'
                  )}
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
  const { t } = useAppTranslation(
    'components/settings/BootcampAffiliateCouponForm.tsx'
  )
  if (isInsider) {
    return (
      <>
        <p className="text-p-base mb-12">
          <Trans
            ns="components/settings/BootcampAffiliateCouponForm.tsx"
            i18nKey="bootcampAffiliateCouponForm.thankYouForBeingInsider"
            components={[
              <a href="https://exercism.org/bootcamp?utm_source=exercism&utm_medium=affiliate_settings"></a>,
              <strong className="font-semibold" />,
            ]}
          />
        </p>
        <p className="text-p-base mb-12">
          <Trans
            ns="components/settings/BootcampAffiliateCouponForm.tsx"
            i18nKey="bootcampAffiliateCouponForm.codeGivesDiscountBootcamp"
            components={{
              strong: <strong className="font-semibold" />,
            }}
          />
        </p>
        <p className="text-p-base mb-16">
          {t('bootcampAffiliateCouponForm.pleaseHelpUsSpreadWord')}
        </p>
      </>
    )
  }

  switch (insidersStatus) {
    case 'eligible':
    case 'eligible_lifetime':
      return (
        <p className="text-p-base mb-16">
          {t('bootcampAffiliateCouponForm.youreEligibleToJoinInsiders')}{' '}
          <a href={insidersPath}>
            {t('bootcampAffiliateCouponForm.getStartedHere')}.
          </a>
        </p>
      )
    default:
      return (
        <p className="text-p-base mb-16">
          <Trans
            i18nKey="bootcampAffiliateCouponForm.insidersCanAccessDiscount"
            ns="components/settings/BootcampAffiliateCouponForm.tsx"
            components={{
              link: (
                <a href="https://exercism.org/bootcamp?utm_source=exercism&utm_medium=affiliate_settings"></a>
              ),
            }}
          />
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
