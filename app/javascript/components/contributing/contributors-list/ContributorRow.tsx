import React from 'react'
import { Contributor } from '../../types'
import {
  Avatar,
  GraphicalIcon,
  HandleWithFlair,
  Reputation,
} from '../../common'

export const ContributorRow = ({
  contributor,
}: {
  contributor: Contributor
}): JSX.Element => {
  return (
    <RowWrapper profile={contributor.links.profile}>
      <div className="rank hidden md:block text-16 md:text-14">
        #{contributor.rank}
      </div>
      <div className="flex-grow flex md:items-center">
        <Avatar src={contributor.avatarUrl} handle={contributor.handle} />
        <div className="flex-grow flex flex-col md:flex-row items-start md:items-center">
          <div className="info mb-4 md:mb-0">
            <h3 className="mb-4 md:mb-0">
              <HandleWithFlair
                handle={contributor.handle}
                flair={contributor.flair}
              />
              <span className="md:hidden text-textColor6 ml-8 text-14">
                #{contributor.rank}
              </span>
            </h3>
            <p>{contributor.activity}</p>
          </div>
          <Reputation value={contributor.reputation} type="primary" />
        </div>
      </div>
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
      <GraphicalIcon
        icon="chevron-right"
        className="action-icon hidden lg:block"
      />
    </a>
  ) : (
    <div className="contributor">
      {children}
      <GraphicalIcon
        icon="transparent"
        className="action-icon hidden lg:block"
      />
    </div>
  )
}
