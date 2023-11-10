import React, { useMemo } from 'react'
import { pluralizeWithNumber } from '@/utils/pluralizeWithNumber'
import { fromNow } from '@/utils/date'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '@/components/common'
import { MostPopularTag } from './MostPopularTag'
import type { Representation } from '@/components/types'
import { SelectedTab } from './Representation'

export const AutomationListElement = ({
  representation,
  selectedTab,
}: {
  representation: Representation
  selectedTab: SelectedTab
}): JSX.Element => {
  const withFeedback = selectedTab === 'with_feedback'
  const isAdminTab = selectedTab === 'admin'
  const ELEMENT_LABELS = useMemo(() => {
    const pluralizeNumSubmissions = pluralizeWithNumber.bind(
      null,
      representation.numSubmissions
    )

    const dateElement: Record<SelectedTab, JSX.Element> = {
      admin: <>{fromNow(representation.feedbackAddedAt)}</>,
      with_feedback: (
        <>
          Last shown
          <br />
          {fromNow(representation.lastSubmittedAt)}
        </>
      ),
      without_feedback: (
        <>
          Last occurence
          <br />
          {fromNow(representation.lastSubmittedAt)}
        </>
      ),
    }

    return {
      counterElement: withFeedback
        ? `Shown ${pluralizeNumSubmissions('time')}`
        : `${pluralizeNumSubmissions('occurrence')}`,
      dateElement: dateElement[selectedTab],
    }
  }, [
    representation.feedbackAddedAt,
    representation.lastSubmittedAt,
    representation.numSubmissions,
    selectedTab,
    withFeedback,
  ])

  return (
    <a className="--representer" href={representation.links.edit}>
      <TrackIcon
        title={representation.track.title}
        iconUrl={representation.track.iconUrl}
      />
      <ExerciseIcon
        title={representation.exercise.title}
        iconUrl={representation.exercise.iconUrl}
      />
      <div className="--info">
        <div className="--exercise-title whitespace-nowrap">
          <div>{representation.exercise.title}</div>{' '}
          {!isAdminTab && representation.appearsFrequently && (
            <MostPopularTag />
          )}
        </div>
        <div className="--track-title">
          in {representation.track.title} (#{representation.id})
        </div>
      </div>
      {isAdminTab && (
        <div className="flex flex-col gap-8 mr-60 w-[160px] text-left">
          {representation.feedbackAuthor?.handle && (
            <div className="flex gap-8 leading-150">
              <GraphicalIcon
                height={14}
                width={14}
                icon="authoring"
                className="filter-textColor6"
              />
              <span
                title={representation.feedbackAuthor?.handle}
                className="truncate"
              >
                {representation.feedbackAuthor?.handle}
              </span>
            </div>
          )}
          {representation.feedbackEditor?.handle && (
            <div className="flex gap-8 leading-150">
              <GraphicalIcon
                height={14}
                width={14}
                icon="edit"
                className="filter-textColor6"
              />
              <span
                title={representation.feedbackEditor?.handle}
                className="truncate"
              >
                {representation.feedbackEditor?.handle}
              </span>
            </div>
          )}
        </div>
      )}
      <div
        className="--feedback-glimpse"
        dangerouslySetInnerHTML={{ __html: representation.feedbackHtml }}
      />
      {!isAdminTab && (
        <div className="--occurencies">{ELEMENT_LABELS['counterElement']}</div>
      )}
      <time className="whitespace-nowrap">{ELEMENT_LABELS['dateElement']}</time>
      <GraphicalIcon
        icon="chevron-right"
        className="action-icon filter-textColor6"
      />
    </a>
  )
}
