import React, { useState, useCallback } from 'react'
import { Contribution } from './Contribution'
import pluralize from 'pluralize'
import { OrderSwitcher } from './contribution-results/OrderSwitcher'
import { MarkAllAsSeenModal } from './contribution-results/MarkAllAsSeenModal'
import { APIResult } from './ContributionsList'

export type Order = 'newest_first' | 'oldest_first'

const DEFAULT_ORDER = 'newest_first'

export const ContributionResults = ({
  data,
  order,
  setOrder,
}: {
  data: APIResult
  setOrder: (order: string) => void
  order: string
}): JSX.Element => {
  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {data.results.length}{' '}
          {pluralize('contribution', data.results.length)}
        </h3>
        <button
          type="button"
          onClick={handleModalOpen}
          className="btn-m btn-default"
        >
          Mark all as seen
        </button>
        <OrderSwitcher
          value={(order || DEFAULT_ORDER) as Order}
          setValue={setOrder}
        />
      </div>
      <div className="reputation-tokens">
        {data.results.map((contribution) => {
          return <Contribution {...contribution} key={contribution.uuid} />
        })}
      </div>
      <MarkAllAsSeenModal
        endpoint={data.meta.links.markAllAsSeen}
        open={modalOpen}
        onClose={handleModalClose}
      />
    </div>
  )
}
