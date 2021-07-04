import React from 'react'
import { Contributor } from '../../types'
import { Avatar, GraphicalIcon, Reputation } from '../../common'

export const ContributorRow = ({
  contributor,
}: {
  contributor: Contributor
}): JSX.Element => {
  return (
    <a
      key={contributor.handle}
      href={contributor.links.profile}
      className="contributor"
    >
      <div className="rank">#{contributor.rank}</div>
      <Avatar src={contributor.avatarUrl} handle={contributor.handle} />
      <div className="info">
        <h3>{contributor.handle}</h3>
        <p>{contributor.activity}</p>
      </div>
      <Reputation value={contributor.reputation} type="primary" />
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
