import React from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { Loading } from './Loading'

const DEFAULT_ERROR = new Error('Unable to load concept')

export const ConceptTooltip = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null => {
  const { data, error, status } = useRequestQuery<{ html: string }>(endpoint, {
    endpoint: endpoint,
    options: {},
  })

  return (
    <div className="c-concept-tooltip">
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
        LoadingComponent={() => <Loading alt="Loading concept data" />}
      >
        {data ? <div dangerouslySetInnerHTML={{ __html: data.html }} /> : null}
      </FetchingBoundary>
    </div>
  )
}
