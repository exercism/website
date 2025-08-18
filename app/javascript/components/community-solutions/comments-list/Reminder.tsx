import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Reminder = (): JSX.Element => {
  const { t } = useAppTranslation('components/community-solutions')
  return (
    <p className="text-p-small text-text-textColor6 mt-16 mb-32">
      {t('commentsList.reminder.rememberComments')}
    </p>
  )
}
