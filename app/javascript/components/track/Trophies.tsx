import React from 'react'
import { GraphicalIcon } from '../common'

type TrophyStatus = 'not_earned' | 'unrevealed' | 'revealed'

export type Trophy = {
  name: string
  criteria: string
  iconName: string
  status: TrophyStatus
}

export type TrophiesProps = {
  trophies: readonly Trophy[]
}

export const Trophies = ({ trophies }: TrophiesProps): JSX.Element => {
  return (
    <div className="trophies">
      {trophies.map((trophy) => (
        <div className="trophy">
          <GraphicalIcon
            icon={trophy.iconName}
            category="graphics"
            width={128}
            height={128}
          />
          <div className="title">{trophy.name}</div>
        </div>
      ))}
    </div>
  )
}
