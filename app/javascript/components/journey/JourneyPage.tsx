import React, {
  useEffect,
  useState,
  useCallback,
  createContext,
  useRef,
} from 'react'
import { GraphicalIcon } from '../common'
import { type TabContext, Tab } from '../common/Tab'
import { ContributionsList } from './ContributionsList'
import { SolutionsList } from './SolutionsList'
import { BadgesList } from './BadgesList'
import { Overview } from './Overview'
import type { Request } from '@/hooks/request-query'

type CategoryId = 'solutions' | 'reputation'

const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => null,
})

export type Category = {
  id: string
  title: string
  icon: string
  path: string
  request: Request
}

export default function JourneyPage({
  defaultCategory,
  categories,
}: {
  defaultCategory: CategoryId
  categories: readonly Category[]
}): JSX.Element {
  const isMounted = useRef(false)
  const [currentCategory, setCurrentCategory] = useState<Category>(() => {
    const category = categories.find((c) => c.id === defaultCategory)

    if (!category) {
      throw new Error('Category not found')
    }

    return category
  })

  const switchToTab = useCallback(
    (id: string) => {
      const category = categories.find((c) => c.id === id)

      if (!category) {
        throw new Error('Category not found')
      }

      setCurrentCategory(category)
    },
    [categories]
  )

  useEffect(() => {
    if (!isMounted.current) {
      isMounted.current = true
      return
    }

    history.pushState(history.state, '', currentCategory.path)
  }, [currentCategory])

  return (
    <TabsContext.Provider
      value={{ current: currentCategory.id, switchToTab: switchToTab }}
    >
      <div className="tabs theme-dark">
        {categories.map((category) => {
          return (
            <Tab key={category.id} context={TabsContext} id={category.id}>
              <GraphicalIcon icon={category.icon} />
              {category.title}
            </Tab>
          )
        })}
      </div>
      {categories.map((category) => {
        return (
          <Tab.Panel id={category.id} context={TabsContext} key={category.id}>
            {category.id === 'overview' ? (
              <Overview
                isEnabled={currentCategory.id === 'overview'}
                request={category.request}
              />
            ) : null}
            {category.id === 'solutions' ? (
              <SolutionsList
                isEnabled={currentCategory.id === 'solutions'}
                request={category.request}
              />
            ) : null}
            {category.id === 'reputation' ? (
              <ContributionsList
                isEnabled={currentCategory.id === 'reputation'}
                request={category.request}
              />
            ) : null}
            {category.id === 'badges' ? (
              <BadgesList
                isEnabled={currentCategory.id === 'badges'}
                request={category.request}
              />
            ) : null}
          </Tab.Panel>
        )
      })}
    </TabsContext.Provider>
  )
}
