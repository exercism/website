import React from 'react'
import { CATEGORY_ICONS } from '../ContributionsSummary'
import { ContributionCategory } from '../../types'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { useCategoryLabels } from './useCategoryLabels'

export const CategorySummary = ({
  category,
}: {
  category: ContributionCategory
}): JSX.Element => {
  const { t } = useAppTranslation('components/profile/contributions-summary')
  const { title, metric } = useCategoryLabels()
  const metricFull = metric(category, 'metricFull')

  return (
    <div className="category">
      <GraphicalIcon icon={CATEGORY_ICONS[category.id]} hex />
      <div className="info">
        <div className="title">{title(category)}</div>
        {metricFull ? <div className="subtitle">{metricFull}</div> : null}
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
