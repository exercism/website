import React, { useState, useCallback } from 'react'
import { Contribution } from './Contribution'
import pluralize from 'pluralize'
import { OrderSwitcher } from './contribution-results/OrderSwitcher'
import { MarkAllAsSeenModal } from './contribution-results/MarkAllAsSeenModal'
import { MarkAllAsSeenButton } from './contribution-results/MarkAllAsSeenButton'
import { APIResult } from './ContributionsList'
import { queryCache, QueryKey } from 'react-query'

export type Order = 'newest_first' | 'oldest_first'

const DEFAULT_ORDER = 'newest_first'

export const ContributionResults = ({
  cacheKey,
  data,
  order,
  setOrder,
}: {
  cacheKey: QueryKey
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

  const handleSuccess = useCallback(
    (response: APIResult) => {
      const oldData = queryCache.getQueryData<APIResult>(cacheKey)

      queryCache.setQueryData(cacheKey, {
        ...oldData,
        meta: { ...oldData?.meta, unseenTotal: response.meta.unseenTotal },
      })
    },
    [cacheKey]
  )

  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {data.results.length}{' '}
          {pluralize('contribution', data.results.length)}
        </h3>
        <MarkAllAsSeenButton
          onClick={handleModalOpen}
          unseenTotal={data.meta.unseenTotal}
        />
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
        onSuccess={handleSuccess}
        onClose={handleModalClose}
      />
    </div>
  )
}
