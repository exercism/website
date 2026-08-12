import React from 'react'
import { HandleWithFlair } from '@/components/common/HandleWithFlair'
import { useUserIdentity } from './useUserIdentity'

export type UserHandleWithFlairProps = {
  handle: string
  size?: 'small' | 'base' | 'medium' | 'large' | 'xlarge'
  className?: string
}

/**
 * The handle itself is rendered immediately (it is immutable and SEO-relevant),
 * with only the flair icon arriving from the endpoint.
 */
export function UserHandleWithFlair({
  handle,
  size = 'base',
  className,
}: UserHandleWithFlairProps): JSX.Element {
  const { data } = useUserIdentity(handle)

  return (
    <HandleWithFlair
      handle={handle}
      flair={data?.flair as never}
      size={size}
      className={className}
    />
  )
}

export default UserHandleWithFlair
