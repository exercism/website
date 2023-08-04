import React from 'react'
import { TrackIcon } from '@/components/common'
import type { AnalyzerFeedback as Props } from '@/components/types'
import { Comment } from '@/components/student/iterations-list/AnalyzerFeedback'
import type { Track } from '@/components/student/IterationsList'

export const BLOCKQUOTE = 'border border-l-6 pl-12 border-borderColor6 mb-16'

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
      <div className={BLOCKQUOTE}>
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
