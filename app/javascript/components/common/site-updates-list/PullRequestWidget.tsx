// i18n-namespace: components/common/site-updates-list/PullRequestWidget.tsx
import React from 'react'
import { fromNow } from '../../../utils/time'
import { GraphicalIcon } from '../GraphicalIcon'
import { Icon } from '../Icon'
import { PullRequest } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const PullRequestWidget = ({
  url,
  title,
  number,
  mergedAt,
  mergedBy,
}: PullRequest): JSX.Element => {
  const { t } = useAppTranslation(
    'components/common/site-updates-list/PullRequestWidget.tsx'
  )
  return (
    <a href={url} className="pull-request" target="_blank" rel="noreferrer">
      <Icon
        icon="pull-request-merge"
        alt={t('pullRequestWidget.pullRequest')}
        category="graphics"
      />
      <div className="details">
        <div className="pr-title">{title}</div>
        <div className="pr-info">
          {t('pullRequestWidget.mergedInfo', {
            number,
            time: fromNow(mergedAt),
            user: mergedBy,
          })}
        </div>
      </div>
      <div className="merged">
        <GraphicalIcon icon="completed-check-circle" />
        {t('pullRequestWidget.merged')}
      </div>
    </a>
  )
}
