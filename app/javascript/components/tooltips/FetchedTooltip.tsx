import React from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { Loading } from './Loading'

export const FetchedTooltip = ({
  endpoint,
  loadingAlt,
  className,
  defaultError,
}: {
  endpoint: string
  loadingAlt: string
  className: string
  defaultError: Error
}): JSX.Element | null => {
  const { data, error, status } = useRequestQuery<{ html: string }>(
    [endpoint],
    {
      endpoint: endpoint,
      options: {},
    }
  )

  return (
    <div className={className}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={defaultError}
        LoadingComponent={() => <Loading alt={loadingAlt} />}
      >
        {data ? <div dangerouslySetInnerHTML={{ __html: data.html }} /> : null}
      </FetchingBoundary>
    </div>
  )
}
