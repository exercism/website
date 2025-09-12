// i18n-key-prefix: solutionList
// i18n-namespace: components/mentoring/queue
import React from 'react'
import { QueryStatus } from '@tanstack/react-query'
import { Pagination } from '@/components/common/Pagination'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { Solution } from './Solution'
import type { APIResponse } from './useMentoringQueue'
import { scrollToTop } from '@/utils/scroll-to-top'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

type Props = {
  resolvedData: APIResponse | undefined
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

const Component = ({ resolvedData, page, setPage }: Props) => {
  const { t } = useAppTranslation()
  return (
    <>
      {resolvedData && resolvedData.results.length > 0 ? (
        <React.Fragment>
          <div className="--solutions">
            {resolvedData.results.length > 0
              ? resolvedData.results.map((solution, key) => (
                  <Solution key={key} {...solution} />
                ))
              : t('solutionList.noDiscussionsFound')}
          </div>
          <footer>
            <Pagination
              disabled={resolvedData === undefined}
              current={page}
              total={resolvedData.meta.totalPages}
              setPage={(p) => {
                setPage(p)
                scrollToTop()
              }}
            />
          </footer>
        </React.Fragment>
      ) : null}
    </>
  )
}
