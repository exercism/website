import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import pluralize from 'pluralize'

export const Count = ({ number }: { number: number }): JSX.Element => {
  const { t } = useAppTranslation('components/community-solutions')
  return (
    <h2 className="text-h4 mb-24">
      {t('commentsList.count.numberOfComments', {
        number: number,
        pluralize: pluralize('comment', number),
      })}
    </h2>
  )
}
