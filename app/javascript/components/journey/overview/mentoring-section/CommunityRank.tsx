import React from 'react'

export const CommunityRank = ({ rank }: { rank: number }): JSX.Element => {
  const classNames = ['c-community-rank-tag', `--top-${rank}`]

  return <div className={classNames.join(' ')}>Top {rank}%</div>
}
