import React from 'react'
import { useHighlighting } from '@/utils/highlight'
import { Icon, TrackIcon } from '@/components/common'
import type {
  AnalyzerFeedback as Props,
  AnalyzerFeedbackComment,
} from '@/components/types'
import type { Track } from '../IterationsList'

export const AnalyzerFeedback = ({
  summary,
  comments,
  track,
  automatedFeedbackInfoLink,
}: Props & {
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
}): JSX.Element => {
  return (
    <div className="c-automated-feedback analyzer-feedback">
      <div className="feedback-header">
        <TrackIcon iconUrl={track.iconUrl} title={track.title} />
        <div className="info">
          Our <strong>{track.title} Analyzer</strong> generated this feedback
          when analyzing your solution.
        </div>
      </div>
      {summary ? <div className="summary">{summary}</div> : null}
      {comments.map((comment, i) => {
        return <Comment key={i} {...comment} />
      })}
      <div className="explanation">
        Exercism provides automated feedback using a number of intelligent tools
        and systems developed by our community.{' '}
        <a href={automatedFeedbackInfoLink}>
          Learn more
          <Icon
            icon="external-link"
            alt="Opens in a new tab"
            className="filter-lightBlue"
          />
        </a>
      </div>
    </div>
  )
}

export const Comment = ({
  type,
  html,
}: AnalyzerFeedbackComment): JSX.Element => {
  const ref = useHighlighting<HTMLDivElement>()

  return (
    <div className="comment" ref={ref}>
      <CommentTag type={type} />
      <div
        className="c-textual-content --small"
        dangerouslySetInnerHTML={{ __html: html }}
      />
    </div>
  )
}

const CommentTag = ({ type }: Pick<AnalyzerFeedbackComment, 'type'>) => {
  switch (type) {
    case 'essential':
      return <div className="tag essential">Essential</div>
    case 'actionable':
      return <div className="tag recommended">Recommended</div>
    default:
      return null
  }
}
