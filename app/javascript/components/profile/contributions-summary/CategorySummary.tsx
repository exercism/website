import React from 'react'
import { CATEGORY_ICONS, CATEGORY_TITLES } from '../ContributionsSummary'
import { ContributionCategory } from '../../types'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const CategorySummary = ({
  category,
}: {
  category: ContributionCategory
}): JSX.Element => {
  const { t } = useAppTranslation('components/profile/contributions-summary')
  return (
    <div className="category">
      <GraphicalIcon icon={CATEGORY_ICONS[category.id]} hex />
      <div className="info">
        <div className="title">{CATEGORY_TITLES[category.id]}</div>
        {category.metricFull ? (
          <div className="subtitle">{category.metricFull}</div>
        ) : null}
      </div>
      <div className="reputation">
        {category.reputation === 0
          ? t('categorySummary.noRep')
          : t('categorySummary.rep', {
              reputation: category.reputation.toLocaleString(),
            })}
      </div>
    </div>
  )
}
