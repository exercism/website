import React from 'react'
import { Avatar } from '../common'

export type AvatarGroupProps = {
  avatarUrls: readonly string[]
  max?: number
  className?: string
}

export function AvatarGroup({
  avatarUrls,
  max = 0,
  className,
}: AvatarGroupProps): JSX.Element {
  return (
    <div className={`c-faces --static ${className}`}>
      {avatarUrls
        .slice(0, max > 0 ? max : avatarUrls.length)
        .map((avatarUrl) => (
          <Avatar
            className="face"
            src={avatarUrl}
            key={`${avatarUrl}${Math.random()}`}
          />
        ))}
      {max > 0 && avatarUrls.length - max > 0 ? (
        <div className="counter">+{Math.min(99, avatarUrls.length - max)}</div>
      ) : null}
    </div>
  )
}
