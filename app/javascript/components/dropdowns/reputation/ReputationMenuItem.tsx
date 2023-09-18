import React from 'react'
import { fromNow } from '@/utils/time'
import { GraphicalIcon, Reputation } from '@/components/common'
import { missingExerciseIconErrorHandler } from '@/components/common/imageErrorHandler'
import { ReputationToken } from '../Reputation'

export const ReputationMenuItem = ({
  internalUrl,
  externalUrl,
  iconUrl,
  text,
  createdAt,
  value,
  isSeen,
}: ReputationToken): JSX.Element => {
  const url = internalUrl ? internalUrl : externalUrl
  const icon = internalUrl ? (
    <GraphicalIcon icon="chevron-right" className="action-icon" />
  ) : (
    <GraphicalIcon icon="external-link" className="action-icon" />
  )

  return (
    <a href={url} className="token">
      <img
        alt=""
        src={iconUrl}
        className="reason-icon"
        onError={missingExerciseIconErrorHandler}
      />
      <div className="content">
        <div
          className="description"
          dangerouslySetInnerHTML={{ __html: text }}
        />
        <div className="earned-on">{fromNow(createdAt)}</div>
      </div>
      <Reputation value={`+${value}`} />
      <div className={'indicator ' + (isSeen ? 'seen' : 'unseen')} />
      {icon}
    </a>
  )
}
