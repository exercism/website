import React from 'react'
import type { MetricUser } from '@/components/types'
import GraphicalIcon from '@/components/common/GraphicalIcon'

export function UserAvatar({
  user,
}: {
  user?: MetricUser
}): JSX.Element | null {
  if (!user)
    return (
      <div className="w-[36px] h-[36px] mr-12 mt-6">
        <GraphicalIcon
          icon="avatar-placeholder"
          className="c-avatar"
          width={36}
          height={36}
        />
      </div>
    )
  return (
    <div className="w-[36px] h-[36px] mr-12 mt-6">
      <img
        src={user.avatarUrl}
        alt={`${user.handle}'s avatar`}
        className="w-[36px] h-[36px] rounded-circle"
      />
    </div>
  )
}
