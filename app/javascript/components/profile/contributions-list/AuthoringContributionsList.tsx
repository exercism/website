import React from 'react'
import { useScrollToTop } from '@/hooks'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import { useList } from '@/hooks/use-list'
import { ExerciseWidget, Pagination } from '@/components/common'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import type { ExerciseAuthorship, PaginatedResult } from '@/components/types'

const DEFAULT_ERROR = new Error('Unable to load authoring contributions')

export const AuthoringContributionsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const { request, setPage } = useList(initialRequest)
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<
      PaginatedResult<ExerciseAuthorship[]>,
      Error | Response
    >([request.endpoint, request.query], request)

  const scrollToTopRef = useScrollToTop<HTMLDivElement>(request.query.page)

  return (
    <ResultsZone isFetching={isFetching}>
      <FetchingBoundary
        error={error}
        status={status}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <React.Fragment>
            <div className="authoring" ref={scrollToTopRef}>
              <div className="exercises">
                {resolvedData.results.map((authorship) => {
                  return (
                    /*large*/
                    <ExerciseWidget
                      key={authorship.exercise.slug}
                      exercise={authorship.exercise}
                      track={authorship.track}
                    />
                  )
                })}
              </div>
            </div>
            <Pagination
              disabled={latestData === undefined}
              current={request.query.page || 1}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </React.Fragment>
        ) : null}
      </FetchingBoundary>
    </ResultsZone>
  )
}
