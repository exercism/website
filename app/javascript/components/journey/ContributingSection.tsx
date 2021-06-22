import React from 'react'
import { TrackContribution } from '../types'
import { ContributionsSummary } from '../profile/ContributionsSummary'
import { GraphicalIcon } from '../common'
import { HeaderSummary } from './contributing-section/HeaderSummary'

type Links = {
  contributions: string
}
export const ContributingSection = ({
  tracks,
  handle,
  links,
}: {
  tracks: readonly TrackContribution[]
  handle: string
  links: Links
}): JSX.Element => {
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
