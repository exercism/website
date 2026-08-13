import React from 'react'
import { useUserIdentity, profilePath } from './useUserIdentity'

export type UserProfileLinkProps = {
  handle: string
  /** The text to render. Always rendered, whether or not a profile exists. */
  text: string
  className?: string
}

/**
 * Renders text, linked to the user's profile if they have one. Profile
 * existence is a user-level fact, so it cannot live in cached page HTML,
 * but the text itself is always rendered immediately.
 */
export function UserProfileLink({
  handle,
  text,
  className,
}: UserProfileLinkProps): JSX.Element {
  const { data } = useUserIdentity(handle)

  if (!data?.hasProfile) return <span className={className}>{text}</span>

  return (
    <a href={profilePath(handle)} className={className}>
      {text}
    </a>
  )
}

export default UserProfileLink
