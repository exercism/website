import React from 'react'
import { Partner } from '../Session'
import { Avatar, Reputation } from '../../common'
import { FavoriteButton } from './FavoriteButton'
import { PreviousSessionsLink } from './PreviousSessionsLink'

export const PartnerInfo = ({ partner }: { partner: Partner }): JSX.Element => {
  return (
    <div className="student-info">
      <div className="info">
        <div className="subtitle">Who you&apos;re mentoring</div>
        <div className="name-block">
          <div className="name">{partner.name}</div>
          <Reputation value={partner.reputation.toString()} type="primary" />
        </div>
        <div className="handle">{partner.handle}</div>
        <div className="bio">
          {partner.bio}
          <span
            className="flags"
            dangerouslySetInnerHTML={{
              __html: '&#127468;&#127463; &#127466;&#127480;',
            }}
          />
          {/*TODO: Map these to codes like above {student.languagesSpoken.join(', ')}*/}
        </div>
        <div className="options">
          {partner.links ? <PartnerInfoActions partner={partner} /> : null}
          <PreviousSessionsLink numSessions={partner.numPreviousSessions} />
        </div>
      </div>
      <Avatar src={partner.avatarUrl} handle={partner.handle} />
    </div>
  )
}

const PartnerInfoActions = ({ partner }: { partner: Partner }) => {
  return (
    <div className="options">
      {partner.isFavorite !== undefined && partner.links?.favorite ? (
        <FavoriteButton
          isFavorite={partner.isFavorite}
          endpoint={partner.links.favorite}
        />
      ) : null}
    </div>
  )
}
