import React, { useState, useEffect } from 'react'
import { GraphicalIcon, Pagination } from '../common'
import { useIsMounted } from 'use-is-mounted'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useList } from '../../hooks/use-list'
import { Contribution as ContributionProps, ExerciseAuthorship } from '../types'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { BuildingContributionsList } from './contributions-list/BuildingContributionsList'
import { MaintainingContributionsList } from './contributions-list/MaintainingContributionsList'
import { AuthoringContributionsList } from './contributions-list/AuthoringContributionsList'

export type Category = {
  title: 'Building' | 'Maintaining' | 'Authoring'
  count: number
  endpoint: string
  icon: string
}

type PaginatedResult = {
  results: readonly ContributionProps[] & readonly ExerciseAuthorship[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
  }
}

const DEFAULT_ERROR = new Error('Unable to load contributions')

export const ContributionsList = ({
  categories,
  userHandle,
}: {
  categories: readonly Category[]
  userHandle: string
}): JSX.Element => {
  const [loadingTab, setLoadingTab] = useState(true)
  const [currentCategory, setCurrentCategory] = useState(categories[0])
  const isMountedRef = useIsMounted()
  const { request, setPage, setEndpoint } = useList({
    endpoint: currentCategory.endpoint,
  })
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    [request.endpoint, request.query],
    request,
    isMountedRef
  )

  useEffect(() => {
    setEndpoint(currentCategory.endpoint)
  }, [currentCategory, setEndpoint])

  useEffect(() => {
    setLoadingTab(false)
  }, [resolvedData])

  const loadTab = (category: Category) => {
    setCurrentCategory(category)
    setLoadingTab(true)
  }

  return (
    <React.Fragment>
      <div className="tabs">
        {categories.map((category) => {
          const classNames = [
            'c-tab',
            currentCategory === category ? 'selected' : '',
          ].filter((className) => className.length > 0)

          return (
            <button
              key={category.title}
              onClick={() => loadTab(category)}
              className={classNames.join(' ')}
            >
              <GraphicalIcon icon={category.icon} hex />
              {category.title}
              <div className="count">{category.count}</div>
            </button>
          )
        })}
      </div>
      <FetchingBoundary
        error={error}
        status={status}
        defaultError={DEFAULT_ERROR}
      >
        <ResultsZone isFetching={isFetching}>
          {resolvedData && !loadingTab ? (
            <React.Fragment>
              <ContributionsContent
                userHandle={userHandle}
                data={resolvedData}
                category={currentCategory}
              />
              <Pagination
                disabled={latestData === undefined}
                current={request.query.page}
                total={resolvedData.meta.totalPages}
                setPage={setPage}
              />
            </React.Fragment>
          ) : null}
        </ResultsZone>
      </FetchingBoundary>
    </React.Fragment>
  )
}

const ContributionsContent = ({
  userHandle,
  category,
  data,
}: {
  userHandle: string
  category: Category
  data: PaginatedResult
}) => {
  switch (category.title) {
    case 'Building':
      return (
        <BuildingContributionsList
          userHandle={userHandle}
          contributions={data.results}
        />
      )
    case 'Maintaining':
      return (
        <MaintainingContributionsList
          userHandle={userHandle}
          contributions={data.results}
        />
      )
    case 'Authoring':
      return <AuthoringContributionsList authorships={data.results} />
    default:
      return null
  }
}
