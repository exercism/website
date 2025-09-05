import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Count = ({ number }: { number: number }): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <h2 className="text-h4 mb-24">
      {t('commentsList.comment', { count: number })}
    </h2>
  )
}
