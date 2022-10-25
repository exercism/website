import React from 'react'
import { Avatar } from '../common'
import { CreditsUsersProp } from './Credits'

export type AvatarGroupProps = {
  users: CreditsUsersProp[]
  overflow: number
  className?: string
}

export function AvatarGroup({
  users,
  overflow,
  className,
}: AvatarGroupProps): JSX.Element {
  return (
    <div className={`c-faces-with-overflow-counter ${className}`}>
      {users.slice(0, 2).map((user) => (
        <Avatar
          className="face"
          handle={user.handle}
          src={user.avatarUrl}
          key={`${user.avatarUrl}${Math.random()}`}
        />
      ))}
      {overflow > 0 ? (
        <div className="overflow-counter">+{overflow}</div>
      ) : null}
    </div>
  )
}
