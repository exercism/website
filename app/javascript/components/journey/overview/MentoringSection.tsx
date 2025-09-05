import React from 'react'
import { GraphicalIcon } from '../../common'
import { MentoredTrackProgressList, MentoringRanks } from '../types'
import { HeaderSummary } from './mentoring-section/HeaderSummary'
import { MentoringChart } from './mentoring-section/MentoringChart'
import { SessionsMentoredSummary } from './mentoring-section/SessionsMentoredSummary'
import { StudentsMentoredSummary } from './mentoring-section/StudentsMentoredSummary'
import { SessionRatioSummary } from './mentoring-section/SessionRatioSummary'
import { TrackSummary } from './mentoring-section/TrackSummary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Props = {
  tracks: MentoredTrackProgressList
  ranks: MentoringRanks
}

export const MentoringSection = ({ tracks, ranks }: Props): JSX.Element => {
  const { t } = useAppTranslation()
  if (tracks.length === 0) {
    return (
      <section className="empty-section">
        <GraphicalIcon icon="mentoring" hex />
        <h3 className="journey-h3 mb-24">
          {t('mentoringSection.youHaventMentoredAnyone')}
        </h3>
        {/* TODO get link from rails */}
        <a href="/mentoring" className="btn-l btn-primary">
          {t('mentoringSection.tryMentoring')}
        </a>
      </section>
    )
  }

  return (
    <section className="mentoring-section">
      <header className="section-header">
        <GraphicalIcon icon="mentoring" hex />
        <h2 className="journey-h2">{t('mentoringSection.yourMentoring')}</h2>
        <HeaderSummary tracks={tracks} />
      </header>
      <div className="content">
        <div className="info">
          <div className="summary-boxes">
            <SessionsMentoredSummary tracks={tracks} rank={ranks.discussions} />
            <StudentsMentoredSummary tracks={tracks} rank={ranks.students} />
            <SessionRatioSummary tracks={tracks} />
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
