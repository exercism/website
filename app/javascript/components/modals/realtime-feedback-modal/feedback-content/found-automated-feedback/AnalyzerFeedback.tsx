import React from 'react'
import { useHighlighting } from '@/utils'
import { TrackIcon } from '@/components/common'
import type {
  AnalyzerFeedback as Props,
  AnalyzerFeedbackComment,
} from '@/components/types'
import type { Track } from '@/components/student/IterationsList'

export const AnalyzerFeedback = ({
  summary,
  comments,
  track,
}: Props & {
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
}): JSX.Element => {
  return (
    <div className="c-automated-feedback analyzer-feedback">
      <div className="border border-l-6 pl-12 border-borderColor6 mb-12">
        {summary ? <div className="summary">{summary}</div> : null}
        {comments.map((comment, i) => {
          return <Comment key={i} {...comment} />
        })}
      </div>
      <div className="feedback-header">
        <TrackIcon iconUrl={track.iconUrl} title={track.title} />
        <div className="info">
          Our <strong>{track.title} Analyzer</strong> generated this feedback
          when analyzing your solution.
        </div>
      </div>
    </div>
  )
}

const Comment = ({ type, html }: AnalyzerFeedbackComment) => {
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
