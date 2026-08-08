import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'
import { UserTooltipSkeleton } from '../common/skeleton/skeletons/UserTooltipSkeleton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export default function UserTooltip({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null {
  const { t } = useAppTranslation('components/tooltips/UserTooltip.tsx')
  const DEFAULT_ERROR = new Error(t('userTooltip.unableToLoadUser'))
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-user-tooltip"
      loadingAlt={t('userTooltip.loadingUserData')}
      LoadingComponent={<UserTooltipSkeleton />}
      defaultError={DEFAULT_ERROR}
    />
  )
}
