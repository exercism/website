import React from 'react'
import { useRequestQuery } from '@/hooks'
import { shortFromNow } from '@/utils/time'
import { Avatar, GraphicalIcon, Tab } from '../common'
import { TabsContext } from '../Editor'
import { Iteration, MentorDiscussion, Track } from '../types'
import { DiscussionPostProps } from '../mentoring/discussion/DiscussionPost'
import { AnalyzerFeedback } from '../student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '../student/iterations-list/RepresenterFeedback'
import { DiscussionPostContent } from '../mentoring/discussion/discussion-post/DiscussionPostContent'

type FeedbackPanelProps = {
  iteration: Pick<Iteration, 'analyzerFeedback' | 'representerFeedback'>
  track: Pick<Track, 'title' | 'iconUrl'>
  automatedFeedbackInfoLink: string
  discussion?: MentorDiscussion
}
export const FeedbackPanel = ({
  iteration,
  track,
  automatedFeedbackInfoLink,
  discussion,
}: FeedbackPanelProps): JSX.Element => {
  const { data, status } = useRequestQuery<{ items: DiscussionPostProps[] }>(
    `posts-discussion-${discussion?.uuid}`,
    { endpoint: discussion?.links.posts, options: { enabled: !!discussion } }
  )

  return (
    <Tab.Panel id="feedback" context={TabsContext}>
      <section className="feedback-pane">
        {iteration ? (
          <FeedbackDetail summary="Automated Feedback">
            <>
              {iteration.representerFeedback ? (
                <RepresenterFeedback {...iteration.representerFeedback} />
              ) : null}
              {iteration.analyzerFeedback ? (
                <AnalyzerFeedback
                  {...iteration.analyzerFeedback}
                  track={track}
                  automatedFeedbackInfoLink={automatedFeedbackInfoLink}
                />
              ) : null}
            </>
          </FeedbackDetail>
        ) : null}
        {discussion ? (
          <FeedbackDetail summary="Mentoring Discussion">
            {status === 'loading' ? (
              <div>Loading...</div>
            ) : (
              <div className="c-discussion-timeline">
                <p className="text-p-base">
                  This is your latest mentoring session for this exercise. To
                  continue the discussion, switch to{' '}
                  <a
                    className="font-semibold text-blue"
                    href="mentor_discussions"
                  >
                    mentoring mode
                  </a>
                  .
                </p>
                {data?.items?.map((post, index) => {
                  return (
                    <ReadonlyDiscussionPostView
                      key={post.uuid}
                      prevIterationIdx={
                        index === 0
                          ? 0
                          : data.items[index >= 1 ? index - 1 : 0].iterationIdx
                      }
                      post={post}
                    />
                  )
                })}
              </div>
            )}
          </FeedbackDetail>
        ) : null}
      </section>
    </Tab.Panel>
  )
}

function FeedbackDetail({
  summary,
  children,
}: {
  summary: string
  children: React.ReactNode
}): JSX.Element {
  return (
    <details className="c-details feedback">
      <summary className="--summary select-none">
        <div className="--summary-inner">
          <span className="summary-title">{summary}</span>
          <span className="--closed-icon">
            <GraphicalIcon icon="chevron-right" />
          </span>
          <span className="--open-icon">
            <GraphicalIcon icon="chevron-down" />
          </span>
        </div>
      </summary>
      {children}
    </details>
  )
}

function ReadonlyDiscussionPostView({
  post,
  className = '',
  prevIterationIdx,
}: {
  post: DiscussionPostProps
  className?: string
  prevIterationIdx: number
}): JSX.Element {
  const classNames = ['post', 'timeline-entry', className].filter(
    (c) => c.length > 0
  )

  return (
    <>
      {prevIterationIdx === post.iterationIdx ? null : (
        <ReadonlyIterationMarker idx={post.iterationIdx} />
      )}
      <div className={classNames.join(' ')}>
        <Avatar
          handle={post.authorHandle}
          src={post.authorAvatarUrl}
          className="timeline-marker"
        />
        <div className="timeline-content">
          <header className="timeline-entry-header">
            <div className="author">{post.authorHandle}</div>
            <time>{shortFromNow(post.updatedAt)}</time>
          </header>
          <DiscussionPostContent contentHtml={post.contentHtml} />
        </div>
      </div>
    </>
  )
}

function ReadonlyIterationMarker({ idx }: Pick<Iteration, 'idx'>): JSX.Element {
  return (
    <div className="timeline-entry iteration-entry">
      <div className="timeline-marker">
        <GraphicalIcon icon="iteration" />
      </div>
      <div className="timeline-content">
        <div className="timeline-entry-header">
          <div className="info">
            <strong>Iteration {idx}</strong>
          </div>
        </div>
      </div>
    </div>
  )
}
