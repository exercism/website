import React from 'react'
import { TrackContribution } from '@/components/types'
import { ContributionsSummary } from '@/components/profile'
import { GraphicalIcon } from '@/components/common'
import { HeaderSummary } from './contributing-section/HeaderSummary'

export type Props = {
  tracks: readonly TrackContribution[]
  handle: string
  links: Links
}

type Links = {
  contributions: string
}

export const ContributingSection = ({
  tracks,
  handle,
  links,
}: Props): JSX.Element => {
  const allTrack = tracks.find((track) => track.slug === null)

  if (!allTrack) {
    throw new Error('No data found for all track')
  }

  if (allTrack.totalReputation === 0) {
    return (
      <section className="empty-section">
        <GraphicalIcon icon="mentoring" hex />
        <h3 className="journey-h3 mb-24">
          You haven&apos;t contributed to Exercism yet
        </h3>
        {/* TODO get link from rails */}
        <a href="/contributing" className="btn-l btn-primary">
          See how you can contribute
        </a>
      </section>
    )
  }
  return (
    <section className="contributing-section">
      <header className="section-header">
        <GraphicalIcon icon="contribute" hex />
        <h2 className="journey-h2">Your contributions</h2>
        <HeaderSummary tracks={tracks} />
        <hr className="c-divider" />
      </header>
      <div className="content">
        <ContributionsSummary
          tracks={tracks}
          handle={handle}
          links={links}
          showHeader={false}
        />
      </div>
    </section>
  )
}
