import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ListDisabled = ({
  isAuthor,
}: {
  isAuthor: boolean
}): JSX.Element => {
  const { t } = useAppTranslation('components/community-solutions')
  if (isAuthor) {
    return (
      <p className="text-16 leading-150 text-textColor6">
        {t('commentsList.listDisabled.disabledCommentsAuthor')}
      </p>
    )
  } else {
    return <p>{t('commentsList.listDisabled.disabledComments')}</p>
  }
}
