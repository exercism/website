import React from 'react'
import type { QueryStatus } from '@tanstack/react-query'
import { Pagination, FilterFallback } from '@/components/common/'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { AutomationListElement } from './AutomationListElement'
import type { APIResponse } from './useMentoringAutomation'
import { SelectedTab } from './Representation'
import { scrollToTop } from '@/utils/scroll-to-top'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

type Props = {
  resolvedData: APIResponse | undefined
  page: number
  setPage: (page: number) => void
  withFeedback: boolean
  selectedTab: SelectedTab
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

function Component({ resolvedData, page, setPage, selectedTab }: Props) {
  return (
    <>
      {resolvedData && resolvedData.results && (
        <React.Fragment>
          <div className="--solutions">
            {resolvedData.results.length > 0 ? (
              resolvedData.results.map((representation, key) => (
                <AutomationListElement
                  selectedTab={selectedTab}
                  key={key}
                  representation={representation}
                />
              ))
            ) : resolvedData.meta.unscopedTotal === 1 ? (
              <NoResultsYet />
            ) : (
              <NoResultsOfQuery />
            )}
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
      )}
    </>
  )
}

function NoResultsOfQuery() {
  const { t } = useAppTranslation(
    'components/mentoring/automation/RepresentationList.tsx'
  )
  return (
    <FilterFallback
      icon="no-result-magnifier"
      title={t('representationList.noSolutionsFound')}
      description={t('representationList.tryChangingFilters')}
    />
  )
}

function NoResultsYet() {
  const { t } = useAppTranslation(
    'components/mentoring/automation/RepresentationList.tsx'
  )
  return (
    <FilterFallback
      icon="automation"
      svgFilter="filter-textColor6"
      title={t('representationList.noSolutionsNeedFeedback')}
      description={t('representationList.checkBackLater')}
    />
  )
}
