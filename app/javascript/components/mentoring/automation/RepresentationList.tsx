import React, { useEffect } from 'react'
import { Pagination } from '../../common/Pagination'
import { FetchingBoundary } from '../../FetchingBoundary'
import { RepresentationsResponse } from './useMentoringAutomation'
import { QueryStatus } from 'react-query'
import { AutomationListElement } from './AutomationListElement'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

type Props = {
  resolvedData: RepresentationsResponse | undefined
  latestData: RepresentationsResponse | undefined
  page: number
  setPage: (page: number) => void
}

export const RepresentationList = ({
  status,
  error,
  ...props
}: { status: QueryStatus; error: unknown } & Props): JSX.Element => {
  return (
    <FetchingBoundary
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
    >
      <Component {...props} />
    </FetchingBoundary>
  )
}

function Component({ resolvedData, latestData, page, setPage }: Props) {
  useEffect(() => {
    console.log('RESOLVED IN COMPONENT:', resolvedData)
  }, [resolvedData])

  return (
    <>
      {resolvedData && resolvedData.results && (
        <React.Fragment>
          <div className="--solutions">
            {resolvedData.results.length > 0
              ? resolvedData.results.map((representation, key) => (
                  <AutomationListElement
                    key={key}
                    representation={representation}
                  />
                ))
              : 'No discussions found'}
          </div>
          <footer>
            <Pagination
              disabled={latestData === undefined}
              current={page}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </footer>
        </React.Fragment>
      )}
    </>
  )
}
