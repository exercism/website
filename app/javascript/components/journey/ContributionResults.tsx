import React, { useState, useCallback } from 'react'
import { Contribution } from './Contribution'
import pluralize from 'pluralize'
import { MarkAllAsSeenModal } from './contribution-results/MarkAllAsSeenModal'
import { MarkAllAsSeenButton } from './contribution-results/MarkAllAsSeenButton'
import { APIResult } from './ContributionsList'
import { QueryKey, useQueryClient } from '@tanstack/react-query'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Order = 'newest_first' | 'oldest_first'

export const ContributionResults = ({
  cacheKey,
  data,
}: {
  cacheKey: QueryKey
  data: APIResult
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey')
  const queryClient = useQueryClient()
  const [modalOpen, setModalOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])

  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  const handleSuccess = useCallback(
    (response: APIResult) => {
      const oldData = queryClient.getQueryData<APIResult>(cacheKey)

      queryClient.setQueryData(cacheKey, {
        ...oldData,
        meta: { ...oldData?.meta, unseenTotal: response.meta.unseenTotal },
      })
    },
    [cacheKey, queryClient]
  )

  return (
    <div>
      <div className="results-title-bar">
        <h3>
          {t('contributionResults.showingContributions', {
            totalCount: data.meta.totalCount,
            contributionLabel: pluralize('contribution', data.meta.totalCount),
          })}
        </h3>
        <MarkAllAsSeenButton
          onClick={handleModalOpen}
          unseenTotal={data.meta.unseenTotal}
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
        unseenTotal={data.meta.unseenTotal}
      />
    </div>
  )
}
