import React from 'react'
import { GraphicalIcon } from '../../common'
import { MentoredTrackProgressList } from '../../types'
import { HeaderSummary } from './mentoring-section/HeaderSummary'
import { MentoringChart } from './mentoring-section/MentoringChart'
import { SessionsMentoredSummary } from './mentoring-section/SessionsMentoredSummary'
import { StudentsMentoredSummary } from './mentoring-section/StudentsMentoredSummary'
import { SessionRatioSummary } from './mentoring-section/SessionRatioSummary'
import { TrackSummary } from './mentoring-section/TrackSummary'

export type Props = {
  tracks: MentoredTrackProgressList
  ranks: Ranks
}

type Ranks = {
  sessions?: number
  students?: number
  ratio?: number
}

export const MentoringSection = ({ tracks, ranks }: Props): JSX.Element => {
  return (
    <section className="mentoring-section">
      <header className="section-header">
        <GraphicalIcon icon="mentoring" hex />
        <h2 className="journey-h2">Your mentoring</h2>
        <HeaderSummary tracks={tracks} />
      </header>
      <div className="content">
        <div className="info">
          <div className="summary-boxes">
            <SessionsMentoredSummary tracks={tracks} rank={ranks.sessions} />
            <StudentsMentoredSummary tracks={tracks} rank={ranks.students} />
            <SessionRatioSummary tracks={tracks} rank={ranks.ratio} />
          </div>
          <div className="track-metrics">
            {tracks.sort().items.map((track) => (
              <TrackSummary key={track.slug} track={track} />
            ))}
          </div>
        </div>
        <MentoringChart tracks={tracks} />
      </div>
    </section>
  )
}
