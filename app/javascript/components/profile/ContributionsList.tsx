import React, { useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import { BuildingContributionsList } from './contributions-list/BuildingContributionsList'
import { MaintainingContributionsList } from './contributions-list/MaintainingContributionsList'
import { AuthoringContributionsList } from './contributions-list/AuthoringContributionsList'
import { OtherContributionsList } from './contributions-list/OtherContributionsList'
import type { Request } from '@/hooks/request-query'

export type Category = {
  title: 'Building' | 'Maintaining' | 'Authoring' | 'Other'
  count: number
  request: Request
  icon: string
}

export default function ContributionsList({
  categories,
}: {
  categories: readonly Category[]
}): JSX.Element {
  const [currentCategory, setCurrentCategory] = useState(categories[0])

  return (
    <React.Fragment>
      <div className="tabs scroll-x-hidden">
        {categories.map((category) => {
          const classNames = [
            'c-tab',
            currentCategory === category ? 'selected' : '',
          ].filter((className) => className.length > 0)

          return (
            <button
              key={category.title}
              onClick={() => setCurrentCategory(category)}
              className={classNames.join(' ')}
            >
              <GraphicalIcon icon={category.icon} hex />
              {category.title}
              <div className="count">{category.count.toLocaleString()}</div>
            </button>
          )
        })}
      </div>
      <ContributionsContent category={currentCategory} />
    </React.Fragment>
  )
}

const ContributionsContent = ({ category }: { category: Category }) => {
  switch (category.title) {
    case 'Building':
      return <BuildingContributionsList request={category.request} />
    case 'Maintaining':
      return <MaintainingContributionsList request={category.request} />
    case 'Authoring':
      return <AuthoringContributionsList request={category.request} />
    case 'Other':
      return <OtherContributionsList request={category.request} />
    default:
      return null
  }
}
