import React from 'react'
import { QueryStatus } from 'react-query'
import { useScrollToTop } from '@/hooks'
import { Pagination } from '@/components/common/Pagination'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { Solution } from './Solution'
import type { APIResponse } from './useMentoringQueue'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

type Props = {
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  page: number
  setPage: (page: number) => void
}

export const SolutionList = ({
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

const Component = ({ resolvedData, latestData, page, setPage }: Props) => {
  const scrollToTopRef = useScrollToTop<HTMLDivElement>(page)

  return (
    <>
      {resolvedData && resolvedData.results.length > 0 ? (
        <React.Fragment>
          <div className="--solutions" ref={scrollToTopRef}>
            {resolvedData.results.length > 0
              ? resolvedData.results.map((solution, key) => (
                  <Solution key={key} {...solution} />
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
      ) : null}
    </>
  )
}
