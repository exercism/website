import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function ThanksForSubmitting({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  const { t } = useAppTranslation('components/modals/upload-video')
  return (
    <>
      <h2 className="text-h2 mb-12">
        {t('thanksForSubmitting.thanksForSubmitting')}
      </h2>
      <p className="text-prose mb-24">
        {t('thanksForSubmitting.approvedVideoMessage')}
      </p>

      <div className="flex">
        <button onClick={onClick} className="w-full btn-primary btn-l grow">
          {t('thanksForSubmitting.noProblemImDone')}
        </button>
      </div>
    </>
  )
}
