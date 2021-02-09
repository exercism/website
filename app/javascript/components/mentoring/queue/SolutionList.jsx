import React, { useState } from 'react'
import { Solution } from './Solution'
import * as Tooltips from '../../tooltips'
import { Pagination } from '../../common/Pagination'
import { Loading } from '../../common/Loading'
import { usePopper } from 'react-popper'

export function SolutionList({
  status,
  resolvedData,
  latestData,
  page,
  setPage,
}) {
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
      {status === 'loading' && <Loading />}
      {status === 'error' && <p>Something went wrong</p>}
      {status === 'success' && resolvedData.results.length > 0 ? (
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
      ) : (
        'No discussions found'
      )}
      {latestData && (
        <footer>
          <Pagination
            current={page}
            total={latestData.meta.totalPages}
            setPage={setPage}
          />
        </footer>
      )}
    </div>
  )
}
