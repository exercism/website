import React from 'react'
import {
  Category,
  CATEGORY_ICONS,
  CATEGORY_TITLES,
} from '../ContributionsSummary'
import { GraphicalIcon } from '../../common'

export const CategorySummary = ({
  category,
}: {
  category: Category
}): JSX.Element => {
  return (
    <div className="category">
      <GraphicalIcon icon={CATEGORY_ICONS[category.id]} hex />
      <div className="info">
        <div className="title">{CATEGORY_TITLES[category.id]}</div>
        {category.metric ? (
          <div className="subtitle">{category.metric}</div>
        ) : null}
      </div>
      <div className="reputation">
        {category.reputation === 0
          ? 'No rep'
          : `${category.reputation.toLocaleString()} rep`}
      </div>
    </div>
  )
}
