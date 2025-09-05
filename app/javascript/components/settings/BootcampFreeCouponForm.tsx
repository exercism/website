// i18n-key-prefix: bootcampFreeCouponForm
// i18n-namespace: components/settings/BootcampFreeCouponForm.tsx
import React, { useState, useCallback } from 'react'
import { fetchJSON } from '@/utils/fetch-json'
import CopyToClipboardButton from '../common/CopyToClipboardButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation()
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
      setError(t('bootcampFreeCouponForm.failedToGenerateCouponCode'))
    } finally {
      setLoading(false)
    }
  }, [links, t])

  return (
    <div>
      <h2 className="!mb-8">
        {t('bootcampFreeCouponForm.freeSeatOnBootcamp')}
      </h2>
      <p className="text-p-base mb-12">
        <Trans
          i18nKey="bootcampFreeCouponForm.lifetimeInsiderEligible"
          ns="components/settings/BootcampFreeCouponForm.tsx"
          components={[
            <a
              href="https://exercism.org/bootcamp?utm_source=exercism&utm_medium=free_settings"
              className="font-bold"
            />,
          ]}
        />
      </p>
      <p className="text-p-base mb-16">
        {t('bootcampFreeCouponForm.claimFreeSeat')}
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
          {loading
            ? t('bootcampFreeCouponForm.generatingCode')
            : t('bootcampFreeCouponForm.clickToGenerateCode')}
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
