import React from 'react'
import { Pagination } from '../../common/Pagination'
import { FetchingBoundary } from '../../FetchingBoundary'
import { APIResponse } from './useMentoringAutomation'
import { QueryStatus } from 'react-query'
import { AutomationListElement } from './AutomationListElement'
import { GraphicalIcon } from '../../common'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

type Props = {
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  page: number
  setPage: (page: number) => void
  withFeedback: boolean
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

function Component({
  resolvedData,
  latestData,
  page,
  setPage,
  withFeedback,
}: Props) {
  return (
    <>
      {resolvedData && resolvedData.results && (
        <React.Fragment>
          <div className="--solutions">
            {resolvedData.results.length > 0 ? (
              resolvedData.results.map((representation, key) => (
                <AutomationListElement
                  withFeedback={withFeedback}
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

function TableFallbackComponent({
  icon,
  title,
  description,
  svgFilter,
}: {
  icon: string
  title: string
  description: string
  svgFilter?: string
}) {
  return (
    <div className="text-center py-40">
      <GraphicalIcon
        className={`w-[48px] h-[48px] m-auto mb-20 ${svgFilter}`}
        icon={icon}
      />
      <div className="text-h5 mb-8 text-textColor6">{title}</div>
      <div className="mb-20 text-textColor6 leading-160 text-16">
        {description}
      </div>
    </div>
  )
}

function NoResultsOfQuery() {
  return (
    <TableFallbackComponent
      icon="no-result-magnifier"
      title="No solutions found."
      description="Try changing your filters to find solutions that need feedback."
    />
  )
}

function NoResultsYet() {
  return (
    <TableFallbackComponent
      icon="automation"
      svgFilter="filter-textColor6"
      title="There are currently no solutions that need feedback."
      description="Check back here later for more!"
    />
  )
}
