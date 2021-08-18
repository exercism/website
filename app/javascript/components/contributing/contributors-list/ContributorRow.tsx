import React from 'react'
import { Contributor } from '../../types'
import { Avatar, GraphicalIcon, Reputation } from '../../common'

export const ContributorRow = ({
  contributor,
}: {
  contributor: Contributor
}): JSX.Element => {
  return (
    <RowWrapper profile={contributor.links.profile}>
      <div className="rank">#{contributor.rank}</div>
      <Avatar src={contributor.avatarUrl} handle={contributor.handle} />
      <div className="info">
        <h3>{contributor.handle}</h3>
        <p>{contributor.activity}</p>
      </div>
      <Reputation value={contributor.reputation} type="primary" />
    </RowWrapper>
  )
}

const RowWrapper = ({
  profile,
  children,
}: React.PropsWithChildren<{ profile?: string }>) => {
  return profile ? (
    <a className="contributor" href={profile}>
      {children}
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  ) : (
    <div className="contributor">
      {children}
      <GraphicalIcon icon="transparent" className="action-icon" />
    </div>
  )
}
