import React, { useState, useEffect, useCallback } from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { useList } from '../../hooks/use-list'
import { useHistory, removeEmpty } from '../../hooks/use-history'
import { CommunitySolution as CommunitySolutionProps } from '../types'
import { CommunitySolution } from '../common/CommunitySolution'
import { Checkbox, Icon, Pagination } from '../common'
import { FetchingBoundary } from '../FetchingBoundary'
import pluralize from 'pluralize'
import { ResultsZone } from '../ResultsZone'
import { OrderSelect } from './exercise-community-solutions-list/OrderSelect'
import { SyncStatusCheckbox } from './exercise-community-solutions-list/SyncStatusCheckbox'
import { TestsStatusCheckbox } from './exercise-community-solutions-list/TestsStatusCheckbox'
import { GenericTooltip } from '../misc/ExercismTippy'

type PaginatedResult = {
  results: CommunitySolutionProps[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

export type Order = 'most_starred' | 'newest'
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
const DEFAULT_ORDER = 'most_starred'

export const ExerciseCommunitySolutionsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const {
    request,
    setPage,
    setOrder,
    setQuery,
    setCriteria: setRequestCriteria,
  } = useList(initialRequest)
  const [criteria, setCriteria] = useState(request.query?.criteria || '')
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    ['exercise-community-solution-list', request.endpoint, request.query],
    request
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const setUpToDate = useCallback(
    (upToDate) => {
      setQuery({
        ...request.query,
        upToDate: upToDate ? true : null,
        page: undefined,
      })
    },
    [request.query, setQuery]
  )

  const setPassedTests = useCallback(
    (passedTests) => {
      setQuery({
        ...request.query,
        passedTests: passedTests ? true : null,
        page: undefined,
      })
    },
    [request.query, setQuery]
  )

  const setPassedHeadTests = useCallback(
    (passedHeadTests) => {
      setQuery({
        ...request.query,
        notPassedHeadTests: passedHeadTests === false ? true : null,
        page: undefined,
      })
    },
    [request.query, setQuery]
  )

  return (
    <div className="lg-container c-community-solutions-list">
      {resolvedData ? (
        <h2>
          {resolvedData.meta.unscopedTotal}{' '}
          {pluralize('person', resolvedData.meta.unscopedTotal)} published
          solutions
        </h2>
      ) : null}
      <div className="c-search-bar">
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={criteria}
          placeholder="Search by user"
        />
        <GenericTooltip
          content={
            <>
              Only show solutions that pass the <strong>latest</strong> tests.
            </>
          }
        >
          <div>
            <Checkbox
              checked={!request.query.notPassedHeadTests}
              setChecked={setPassedHeadTests}
            >
              <Icon
                icon="golden-check"
                alt="Only show solution that pass the tests of the latest version of this exercise"
              />
            </Checkbox>
          </div>
        </GenericTooltip>
        <GenericTooltip content="Only show solutions that pass the tests as they were at the time when the student solved the exercise.">
          <div>
            <Checkbox
              checked={request.query.passedTests}
              setChecked={setPassedTests}
            >
              <div
                className={`c-iteration-processing-status --passed`}
                role="status"
                aria-label="Only show solutions that pass the tests"
              >
                <div role="presentation" className="--dot"></div>
                <div className="--status">Passed</div>
              </div>
            </Checkbox>
          </div>
        </GenericTooltip>

        <GenericTooltip content="Only show solutions that are up to date.">
          <div>
            <Checkbox checked={request.query.upToDate} setChecked={setUpToDate}>
              <Icon
                icon="up-to-date"
                alt="Only show solutions that are up-to-date with the latest version of this exercise"
              />
            </Checkbox>
          </div>
        </GenericTooltip>
        <OrderSelect
          value={request.query.order || DEFAULT_ORDER}
          setValue={setOrder}
        />
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
                current={request.query.page}
                total={resolvedData.meta.totalPages}
                setPage={setPage}
              />
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
