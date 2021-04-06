import React, { useState } from 'react'
import { Solution } from './Solution'
import * as Tooltips from '../../tooltips'
import { Pagination } from '../../common/Pagination'
import { usePopper } from 'react-popper'
import { FetchingBoundary } from '../../FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

export const SolutionList = ({ status, error, ...props }) => {
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

function Component({ resolvedData, latestData, page, setPage }) {
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
    <>
      {resolvedData.results.length > 0 ? (
        <>
          <div className="--solutions">
            {resolvedData.results.length > 0
              ? resolvedData.results.map((solution, key) => (
                  <Solution
                    key={key}
                    {...solution}
                    showMoreInformation={(e) =>
                      showTooltip(e.target, solution.tooltipUrl)
                    }
                    hideMoreInformation={() => hideTooltip()}
                  />
                ))
              : 'No discussions found'}
          </div>
          <div ref={setTooltipElement}>
            {tooltipTrigger ? (
              <Tooltips.MentoredStudent
                endpoint={tooltipTrigger.endpoint}
                styles={styles.popper}
              />
            ) : null}
          </div>
          <footer>
            <Pagination
              disabled={latestData === undefined}
              current={page}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </footer>
        </>
      ) : null}
    </>
  )
}
