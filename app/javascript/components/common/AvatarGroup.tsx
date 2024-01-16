import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { Avatar } from '../common'
import { User } from '../types'

export type AvatarGroupProps = {
  users: User[]
  overflow: number
  className?: string
}

export function AvatarGroup({
  users,
  overflow,
  className,
}: AvatarGroupProps): JSX.Element {
  return (
    <div
      className={assembleClassNames('c-faces-with-overflow-counter', className)}
    >
      {users &&
        users
          .slice(0, 2)
          .map((user) => (
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
