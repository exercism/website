import React from 'react'
import { EmptyList } from './EmptyList'
import { List } from './List'
import { Count } from './Count'
import { ResultsZone } from '../../ResultsZone'
import { FetchingBoundary } from '../../FetchingBoundary'
import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'
import { SolutionComment } from '../../types'
import { QueryKey } from 'react-query'

const DEFAULT_ERROR = new Error('Unable to load comments')

export type APIResponse = {
  items: readonly SolutionComment[]
}

export const ListContainer = ({
  request,
  cacheKey,
}: {
  request: Request
  cacheKey: QueryKey
}): JSX.Element => {
  const { resolvedData, status, error, isFetching } = usePaginatedRequestQuery<
    APIResponse
  >(cacheKey, request)

  return (
    <ResultsZone isFetching={isFetching}>
      <FetchingBoundary
        error={error}
        status={status}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <React.Fragment>
            <Count number={resolvedData.items.length} />
            {resolvedData.items.length !== 0 ? (
              <List cacheKey={cacheKey} comments={resolvedData.items} />
            ) : (
              <EmptyList />
            )}
          </React.Fragment>
        ) : null}
      </FetchingBoundary>
    </ResultsZone>
  )
}
