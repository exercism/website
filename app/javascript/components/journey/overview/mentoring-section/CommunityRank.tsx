// i18n-key-prefix: communityRank
// i18n-namespace: components/journey/overview/mentoring-section
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const CommunityRank = ({ rank }: { rank: number }): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/mentoring-section'
  )
  const classNames = ['c-community-rank-tag', `--top-${rank}`]

  return (
    <div className={classNames.join(' ')}>
      {t('communityRank.topRank', { rank })}
    </div>
  )
}
