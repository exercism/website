import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'
import { UserTooltipSkeleton } from '../common/skeleton/skeletons/UserTooltipSkeleton'

const DEFAULT_ERROR = new Error('Unable to load user')

export default function UserTooltip({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null {
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-user-tooltip"
      loadingAlt="Loading user data"
      LoadingComponent={<UserTooltipSkeleton />}
      defaultError={DEFAULT_ERROR}
    />
  )
}
