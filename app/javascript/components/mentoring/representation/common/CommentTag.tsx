// i18n-key-prefix: commentTag
// i18n-namespace: components/mentoring/representation/common
import React from 'react'
import { RepresentationFeedbackType } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const CommentTag = ({
  type,
}: {
  type: RepresentationFeedbackType
}): JSX.Element | null => {
  const { t } = useAppTranslation('components/mentoring/representation/common')
  switch (type) {
    case 'essential':
      return (
        <div className="text-13 leading-170 font-mono font-bold rounded-3 px-8 mb-8 bg-red text-white !w-fit">
          {t('commentTag.essential')}
        </div>
      )
    case 'actionable':
      return (
        <div className="text-13 leading-170 font-mono font-bold rounded-3 px-8 mb-8 bg-warning text-white !w-fit">
          {t('commentTag.recommended')}
        </div>
      )
    default:
      return null
  }
}
