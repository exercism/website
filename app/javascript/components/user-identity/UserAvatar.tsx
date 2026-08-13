import React from 'react'
import { Avatar } from '@/components/common/Avatar'
import { useUserIdentity, profilePath } from './useUserIdentity'

export type UserAvatarProps = {
  handle: string
  /** Wrap the avatar in a link to the user's profile, if they have one */
  link?: boolean
  className?: string
}

export function UserAvatar({
  handle,
  link = false,
  className,
}: UserAvatarProps): JSX.Element {
  const { data } = useUserIdentity(handle)

  // Reserve the layout space before the URL arrives
  if (!data) {
    return <div className={`c-avatar ${className || ''}`} />
  }

  const avatar = (
    <Avatar src={data.avatarUrl} handle={handle} className={className} />
  )

  if (!link || !data.hasProfile) return avatar

  return <a href={profilePath(handle)}>{avatar}</a>
}

export default UserAvatar
