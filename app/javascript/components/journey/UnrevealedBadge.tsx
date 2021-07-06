import React, { useState, useCallback } from 'react'
import { Badge as BadgeProps } from '../types'
import { useIsMounted } from 'use-is-mounted'
import { useMutation, queryCache, QueryKey } from 'react-query'
import { FormButton } from '../common'
import { ErrorMessage, ErrorBoundary } from '../ErrorBoundary'
import { sendRequest } from '../../utils/send-request'
import { typecheck } from '../../utils/typecheck'
import { PaginatedResult } from '../common/SearchableList'
import { BadgeModal } from '../modals/BadgeModal'

const DEFAULT_ERROR = new Error('Unable to reveal badge')

export const UnrevealedBadge = ({
  badge,
  cacheKey,
}: {
  badge: BadgeProps
  cacheKey: QueryKey
}): JSX.Element => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [revealedBadge, setRevealedBadge] = useState<BadgeProps | null>(null)

  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<BadgeProps | undefined>(
    () => {
      return sendRequest({
        endpoint: badge.links.reveal,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<BadgeProps>(json, 'badge')
      })
    },
    {
      onSuccess: (badge) => {
        if (!badge) {
          return
        }

        setRevealedBadge(badge)
        setIsModalOpen(true)
      },
    }
  )

  const updateCache = useCallback(() => {
    const oldData = queryCache.getQueryData<PaginatedResult>(cacheKey)

    if (!oldData || !revealedBadge) {
      return
    }

    queryCache.setQueryData(cacheKey, {
      ...oldData,
      results: oldData.results.map((oldBadge) => {
        return oldBadge.uuid === revealedBadge.uuid ? revealedBadge : oldBadge
      }),
    })
  }, [cacheKey, revealedBadge])

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
