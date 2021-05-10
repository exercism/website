import React, {
  useEffect,
  useState,
  useCallback,
  createContext,
  useRef,
} from 'react'
import { Request } from '../../hooks/request-query'
import { GraphicalIcon } from '../common'
import { TabContext, Tab } from '../common/Tab'
import { ContributionsList } from './ContributionsList'
import { SolutionsList } from './SolutionsList'
import { BadgesList } from './BadgesList'

type CategoryId = 'solutions' | 'reputation'

const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export type Category = {
  id: string
  title: string
  icon: string
  path: string
  request: Request
}

export const JourneyPage = ({
  defaultCategory,
  categories,
}: {
  defaultCategory: CategoryId
  categories: readonly Category[]
}): JSX.Element => {
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
      <div className="tabs">
        {categories.map((category) => {
          return (
            <Tab key={category.id} context={TabsContext} id={category.id}>
              <GraphicalIcon icon={category.icon} />
              {category.title}
            </Tab>
          )
        })}
      </div>
      <div>
        {categories.map((category) => {
          return (
            <Tab.Panel id={category.id} context={TabsContext} key={category.id}>
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
      </div>
    </TabsContext.Provider>
  )
}
