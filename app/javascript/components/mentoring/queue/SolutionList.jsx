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
  const [referencedElement, setReferencedElement] = useState(null)
  const [tooltipElement, setTooltipElement] = useState(null)
  const [tooltipEndpoint, setTooltipEndpoint] = useState(null)
  const { styles } = usePopper(referencedElement, tooltipElement)

  const showTooltip = (referenceElement, tooltipUrl) => {
    setReferencedElement(referenceElement)
    setTooltipEndpoint(tooltipUrl)
  }

  const hideTooltip = () => {
    setTooltipEndpoint(null)
    setReferencedElement(null)
  }

  return (
    <div>
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess && (
        <>
          <table>
            <thead>
              <tr>
                <th>Track icon</th>
                <th>Mentee avatar</th>
                <th>Mentee handle</th>
                <th>Exercise title</th>
                <th>Starred?</th>
                <th>Mentored previously?</th>
                <th>Status</th>
                <th>Updated at</th>
                <th>URL</th>
              </tr>
            </thead>
            <tbody>
              {resolvedData.results.map((solution, key) => (
                <Solution
                  key={key}
                  {...solution}
                  onMouseEnter={(e) =>
                    showTooltip(e.target, solution.tooltipUrl)
                  }
                  onMouseLeave={() => hideTooltip()}
                />
              ))}
            </tbody>
          </table>
          <div ref={setTooltipElement}>
            {tooltipEndpoint && (
              <Tooltips.Student
                endpoint={tooltipEndpoint}
                styles={styles.popper}
              />
            )}
          </div>
        </>
      )}
      {latestData && (
        <Pagination
          current={request.query.page}
          total={latestData.meta.total}
          setPage={setPage}
        />
      )}
    </div>
  )
}
