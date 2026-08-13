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
 * The reputation value arrives after paint, so the placeholder has to reserve
 * the whole badge - not just its text - or the surrounding layout shifts once
 * it lands.
 *
 * The badge is mostly chrome, and how much depends on the variant:
 *   .c-primary-reputation  24px icon + 8px gap + 32px padding + 6px border
 *   .c-primary-reputation.--small  16px icon + 8px gap + 16px padding + 6px border
 *   .c-reputation          24px icon + 6px gap + 16px padding + 2px border
 * Plus ~4 characters for the number itself. Heights come from each badge's own
 * line-height. `plain` renders a bare number inline, so it only needs the text.
 */
function placeholderStyle(
  plain: boolean,
  type: 'primary' | 'common',
  size?: 'small' | 'large'
): React.CSSProperties {
  if (plain) return { minWidth: '4ch' }

  if (type === 'primary') {
    return size === 'small'
      ? { minWidth: 'calc(46px + 4ch)', minHeight: '30px' }
      : { minWidth: 'calc(70px + 4ch)', minHeight: '32px' }
  }

  return { minWidth: 'calc(48px + 4ch)', minHeight: '28px' }
}

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
      className="inline-flex items-center"
      style={placeholderStyle(plain, type, size)}
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
