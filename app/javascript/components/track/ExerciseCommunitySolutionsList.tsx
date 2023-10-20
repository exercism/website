import React, { useState, useEffect, useCallback } from 'react'
import pluralize from 'pluralize'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { scrollToTop } from '@/utils/scroll-to-top'
import { Checkbox, Icon, Pagination } from '@/components/common'
import CommunitySolution from '../common/CommunitySolution'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { OrderSelect } from './exercise-community-solutions-list/OrderSelect'
import type {
  CommunitySolution as CommunitySolutionProps,
  PaginatedResult,
} from '@/components/types'

export type Order =
  | 'most_popular'
  | 'newest'
  | 'oldest'
  | 'fewest_loc'
  | 'highest_reputation'
export type SyncStatus = undefined | 'up_to_date' | 'out_of_date'
export type TestsStatus =
  | undefined
  | 'not_queued'
  | 'queued'
  | 'passed'
  | 'failed'
  | 'errored'
  | 'exceptioned'
  | 'cancelled'

const DEFAULT_ERROR = new Error('Unable to pull solutions')
const DEFAULT_ORDER: Order = 'most_popular'

export function ExerciseCommunitySolutionsList({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element {
  const {
    request,
    setPage,
    setOrder,
    setCriteria: setRequestCriteria,
  } = useList(initialRequest)
  const [criteria, setCriteria] = useState(request.query.criteria)
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<
      PaginatedResult<CommunitySolutionProps[]>,
      Error | Response
    >(
      ['exercise-community-solution-list', request.endpoint, request.query],
      request
    )

  useEffect(() => {
    const handler = setTimeout(() => {
      if (criteria !== undefined && criteria !== null)
        setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <div
      data-scroll-top-anchor="exercise-community-solutions-list"
      className="lg-container c-community-solutions-list"
    >
      {resolvedData ? (
        <h2>
          Explore {resolvedData.meta.unscopedTotal} unique{' '}
          {pluralize('solution', resolvedData.meta.unscopedTotal)}
        </h2>
      ) : null}
      <div className="c-search-bar md:flex-row flex-col">
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={criteria || ''}
          placeholder="Search by code"
        />
        <div className="flex items-center md:w-[unset] w-100 justify-between sm:flex-nowrap flex-wrap sm:gap-y-0 gap-y-24">
          <OrderSelect
            value={request.query.order || DEFAULT_ORDER}
            setValue={setOrder}
          />
        </div>
      </div>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <React.Fragment>
              <div className="solutions grid-cols-1 md:grid-cols-2 xl:grid-cols-3">
                {resolvedData.results.map((solution) => {
                  return (
                    <CommunitySolution
                      key={solution.uuid}
                      solution={solution}
                      context="exercise"
                    />
                  )
                })}
              </div>
              <Pagination
                disabled={latestData === undefined}
                current={request.query.page || 1}
                total={resolvedData.meta.totalPages}
                setPage={(p) => {
                  setPage(p)
                  scrollToTop('exercise-community-solutions-list', 32)
                }}
              />
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}

export default ExerciseCommunitySolutionsList
