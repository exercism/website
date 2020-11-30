import React, { useState } from 'react'
import { Solution } from './Solution'
import * as Tooltips from '../../tooltips'
import { Pagination } from '../Pagination'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'
import { usePopper } from 'react-popper'

export function SolutionList({ request, setPage }) {
  const {
    isLoading,
    isError,
    isSuccess,
    resolvedData,
    latestData,
  } = usePaginatedRequestQuery('mentor-solutions-list', request)
  const [tooltipTrigger, setTooltipTrigger] = useState(null)
  const [tooltipElement, setTooltipElement] = useState(null)

  const { styles } = usePopper(tooltipTrigger?.element, tooltipElement)

  const showTooltip = (referenceElement, tooltipUrl) => {
    setTooltipTrigger({ element: referenceElement, endpoint: tooltipUrl })
  }

  const hideTooltip = () => {
    setTooltipTrigger(null)
  }

  return (
    <div>
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess && (
        <>
          <div className="--solutions">
            {resolvedData.results.map((solution, key) => (
              <Solution
                key={key}
                {...solution}
                showMoreInformation={(e) =>
                  showTooltip(e.target, solution.tooltipUrl)
                }
                hideMoreInformation={() => hideTooltip()}
              />
            ))}
          </div>
          <div ref={setTooltipElement}>
            {tooltipTrigger ? (
              <Tooltips.MentoredStudent
                endpoint={tooltipTrigger.endpoint}
                styles={styles.popper}
              />
            ) : null}
          </div>
        </>
      )}
      {latestData && (
        <footer>
          <Pagination
            current={request.query.page}
            total={latestData.meta.total}
            setPage={setPage}
          />
        </footer>
      )}
    </div>
  )
}
