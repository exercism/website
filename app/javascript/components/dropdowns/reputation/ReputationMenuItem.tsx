import React from 'react'
import { fromNow } from '../../../utils/time'
import { GraphicalIcon, Reputation } from '../../common'
import { ReputationToken } from '../Reputation'

export const ReputationMenuItem = ({
  url,
  iconName,
  text,
  awardedAt,
  value,
  isSeen,
}: ReputationToken): JSX.Element => {
  return (
    <a href={url} className="token">
      <GraphicalIcon icon={iconName} className="reason-icon" />
      <div className="content">
        <div
          className="description"
          dangerouslySetInnerHTML={{ __html: text }}
        />
        <div className="awarded-at">{fromNow(awardedAt)}</div>
      </div>
      <Reputation value={value} />
      {isSeen ? <div className="seen" /> : <div className="unseen" />}
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
