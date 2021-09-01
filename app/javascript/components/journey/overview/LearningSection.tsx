import React from 'react'
import { GraphicalIcon } from '../../common'
import { TrackProgressList } from '../types'
import { HeaderSummary } from './learning-section/HeaderSummary'
import { TracksEnrolledSummary } from './learning-section/TracksEnrolledSummary'
import { ExercisesCompletedSummary } from './learning-section/ExercisesCompletedSummary'
import { ConceptsLearntSummary } from './learning-section/ConceptsLearntSummary'
import { LearningOverview } from './learning-section/LearningOverview'
import { TrackSummary } from './learning-section/TrackSummary'
import { LearningStats } from './learning-section/LearningStats'

export type Props = {
  tracks: TrackProgressList
  links: Links
}

type Links = {
  solutions: string
  fable: string
}

export const LearningSection = ({ tracks, links }: Props): JSX.Element => {
  return (
    <section className="learning-section">
      <header className="section-header">
        <GraphicalIcon icon="exercises" hex />
        <h2 className="journey-h2">Your learning</h2>
        <HeaderSummary tracks={tracks} />
      </header>
      <div className="summary-boxes">
        <TracksEnrolledSummary tracks={tracks} />
        <ExercisesCompletedSummary tracks={tracks} />
        <ConceptsLearntSummary tracks={tracks} />
      </div>
      <LearningOverview tracks={tracks} />
      <div className="tracks">
        {tracks.sort().items.map((track, idx) => (
          <TrackSummary
            key={track.slug}
            track={track}
            avgVelocity={null}
            expanded={idx == 0}
          />
        ))}
      </div>
      {/*<LearningStats tracks={tracks} links={links} />*/}
    </section>
  )
}
