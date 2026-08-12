import React from 'react'
import { Reputation } from '@/components/common/Reputation'
import { useUserIdentity } from './useUserIdentity'

export type UserReputationProps = {
  handle: string
  /** When given, the track-scoped reputation is shown rather than the total */
  track?: string
  size?: 'small' | 'large'
  type?: 'primary' | 'common'
  /** Render just the number, with no badge around it */
  plain?: boolean
}

/**
 * A ~4 character wide placeholder, so that values like "1.2k" and "847"
 * settle inside the reserved box rather than reflowing what surrounds them.
 */
const PLACEHOLDER_WIDTH = '4ch'

export function UserReputation({
  handle,
  track,
  size,
  type = 'common',
  plain = false,
}: UserReputationProps): JSX.Element {
  const { data } = useUserIdentity(handle)

  const value = (() => {
    if (!data) return null
    if (!track) return data.reputation.total

    return (data.reputation.tracks[track] || 0).toLocaleString()
  })()

  return (
    <span
      className="inline-flex"
      style={{ minWidth: PLACEHOLDER_WIDTH }}
      data-handle={handle}
    >
      {value === null ? null : plain ? (
        value
      ) : (
        <Reputation value={value} size={size} type={type} />
      )}
    </span>
  )
}

export default UserReputation
