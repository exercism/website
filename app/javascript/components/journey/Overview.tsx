import React from 'react'
import {
  LearningSection,
  Props as LearningSectionProps,
} from './overview/LearningSection'
import {
  MentoringSection,
  Props as MentoringSectionProps,
} from './overview/MentoringSection'
import {
  ContributingSection,
  Props as ContributingSectionProps,
} from './overview/ContributingSection'
import {
  BadgesSection,
  Props as BadgesSectionProps,
} from './overview/BadgesSection'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { ResultsZone } from '../ResultsZone'
import { FetchingBoundary } from '../FetchingBoundary'
import {
  MentoringTotals,
  MentoringRanks,
  MentoredTrackProgressList,
  MentoredTrackProgress,
  TrackProgress,
  TrackProgressList,
} from './types'
import { TrackContribution, Badge, BadgeList } from '../types'

type JourneyOverview = {
  learning: { tracks: readonly TrackProgress[] } & Omit<
    LearningSectionProps,
    'tracks'
  >
  mentoring: {
    tracks: readonly MentoredTrackProgress[]
    totals: MentoringTotals
    ranks: MentoringRanks
  } & Omit<MentoringSectionProps, 'tracks'>
  contributing: { tracks: readonly TrackContribution[] } & Omit<
    ContributingSectionProps,
    'tracks'
  >
  badges: { badges: readonly Badge[] } & Omit<BadgesSectionProps, 'badges'>
}

const DEFAULT_ERROR = new Error('Unable to load journey overview')

const formatData = ({ overview }: { overview: JourneyOverview }) => {
  return {
    overview: {
      learning: {
        ...overview.learning,
        tracks: new TrackProgressList({ items: overview.learning.tracks }),
      },
      mentoring: {
        ...overview.mentoring,
        tracks: new MentoredTrackProgressList({
          items: overview.mentoring.tracks,
          totals: overview.mentoring.totals,
          ranks: overview.mentoring.ranks,
        }),
      },
      contributing: {
        ...overview.contributing,
        tracks: overview.contributing.tracks.map(
          (track) => new TrackContribution(track)
        ),
      },
      badges: {
        ...overview.badges,
        badges: new BadgeList({ items: overview.badges.badges }),
      },
    },
  }
}

export const Overview = ({
  request,
  isEnabled,
}: {
  request: Request
  isEnabled: boolean
}): JSX.Element => {
  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<{
    overview: JourneyOverview
  }>(['journey-overview'], {
    ...request,
    options: { ...request.options, enabled: isEnabled },
  })
  const formattedData = resolvedData ? formatData(resolvedData) : null

  return (
    <article className="overview-tab theme-dark">
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {formattedData ? (
            <React.Fragment>
              <div className="md-container">
                <LearningSection {...formattedData.overview.learning} />
                <MentoringSection {...formattedData.overview.mentoring} />
              </div>
              <div className="lg-container">
                <ContributingSection {...formattedData.overview.contributing} />
              </div>
              <div className="md-container">
                <BadgesSection {...formattedData.overview.badges} />
              </div>
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </article>
  )
}
