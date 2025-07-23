// i18n-key-prefix: pullRequestLink
// i18n-namespace: components/track/activity-ticker
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function PullRequestLink({
  pullRequest,
}: {
  pullRequest: Record<'htmlUrl', string>
}) {
  const { t } = useAppTranslation('components/track/activity-ticker')
  return (
    <span className="inline-flex">
      &nbsp;
      <a
        href={pullRequest.htmlUrl}
        className="flex flex-row items-center font-semibold text-prominentLinkColor"
      >
        {t('pullRequestLink.pullRequest')}
      </a>
      .
    </span>
  )
}
