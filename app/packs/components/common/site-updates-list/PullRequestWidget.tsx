import React from 'react'
import { fromNow } from '../../../utils/time'
import { GraphicalIcon } from '../GraphicalIcon'
import { Icon } from '../Icon'
import { PullRequest } from '../../types'

export const PullRequestWidget = ({
  url,
  title,
  number,
  mergedAt,
  mergedBy,
}: PullRequest): JSX.Element => {
  return (
    <a href={url} className="pull-request" target="_blank" rel="noreferrer">
      <Icon icon="pull-request-merge" alt="Pull Request" category="graphics" />
      <div className="details">
        <div className="pr-title">{title}</div>
        <div className="pr-info">
          #{number} merged {fromNow(mergedAt)} by {mergedBy}
        </div>
      </div>
      <div className="merged">
        <GraphicalIcon icon="completed-check-circle" />
        Merged
      </div>
    </a>
  )
}
