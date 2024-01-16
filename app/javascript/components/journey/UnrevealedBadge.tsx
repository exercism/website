import React, { useState, useCallback } from 'react'
import { useMutation, QueryKey, useQueryClient } from '@tanstack/react-query'
import { typecheck } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { FormButton } from '@/components/common/FormButton'
import { ErrorMessage, ErrorBoundary } from '@/components/ErrorBoundary'
import { BadgeModal } from '@/components/modals/BadgeModal'
import type { Badge as BadgeProps, PaginatedResult } from '@/components/types'

const DEFAULT_ERROR = new Error('Unable to reveal badge')

export const UnrevealedBadge = ({
  badge,
  cacheKey,
}: {
  badge: BadgeProps
  cacheKey: QueryKey
}): JSX.Element => {
  const queryClient = useQueryClient()
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [revealedBadge, setRevealedBadge] = useState<BadgeProps | null>(null)
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<BadgeProps>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: badge.links.reveal,
        method: 'PATCH',
        body: null,
      })

      return fetch.then((json) => typecheck<BadgeProps>(json, 'badge'))
    },
    {
      onSuccess: (badge) => {
        setRevealedBadge(badge)
        setIsModalOpen(true)
      },
    }
  )

  const updateCache = useCallback(() => {
    const oldData =
      queryClient.getQueryData<PaginatedResult<BadgeProps[]>>(cacheKey)

    if (!oldData || !revealedBadge) {
      return
    }

    queryClient.setQueryData(cacheKey, {
      ...oldData,
      results: oldData.results.map((oldBadge) => {
        return oldBadge.uuid === revealedBadge.uuid ? revealedBadge : oldBadge
      }),
    })
  }, [cacheKey, revealedBadge, queryClient])

  return (
    <React.Fragment>
      <FormButton
        status={status}
        className="c-badge"
        onClick={() => mutation()}
      >
        <div className={`c-badge-medallion --${badge.rarity} --unrevealed`}>
          <div className="--unknown">?</div>
        </div>
        <div className="--info">
          <div className="--name">Unrevealed</div>
          <div className="--desc">Click/tap to reveal</div>
        </div>
      </FormButton>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
      {revealedBadge ? (
        <BadgeModal
          badge={revealedBadge}
          open={isModalOpen}
          onClose={() => {
            setIsModalOpen(false)
            updateCache()
          }}
          wasUnrevealed
        />
      ) : null}
    </React.Fragment>
  )
}
