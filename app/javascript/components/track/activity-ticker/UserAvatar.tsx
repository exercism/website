import React from 'react'
import type { MetricUser } from '@/components/types'

export function UserAvatar({
  user,
}: {
  user?: MetricUser
}): JSX.Element | null {
  if (!user) return null
  return (
    <img
      src={user.avatarUrl}
      alt={`${user.handle}'s avatar`}
      className="w-[36px] h-[36px] rounded-circle mr-12"
    />
  )
}
