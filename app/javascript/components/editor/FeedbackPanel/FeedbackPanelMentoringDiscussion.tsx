import React from 'react'
import { useRequestQuery } from '@/hooks'
import { shortFromNow } from '@/utils/time'
import { Iteration } from '@/components/types'
import { Avatar, GraphicalIcon } from '@/components/common'
import { DiscussionPostContent } from '@/components/mentoring/discussion/discussion-post/DiscussionPostContent'
import { DiscussionPostProps } from '@/components/mentoring/discussion/DiscussionPost'
import { FeedbackPanelProps } from './FeedbackPanel'
import { FeedbackDetail } from './FeedbackDetail'

export function MentoringDiscussion({
  discussion,
  open,
}: Pick<FeedbackPanelProps, 'discussion'> & {
  open?: boolean
}): JSX.Element | null {
  const { data, status } = useRequestQuery<{ items: DiscussionPostProps[] }>(
    `posts-discussion-${discussion?.uuid}`,
    { endpoint: discussion?.links.posts, options: { enabled: !!discussion } }
  )
  if (discussion) {
    return (
      <FeedbackDetail open={open} summary="Mentoring Discussion">
        {status === 'loading' ? (
          <div>Loading...</div>
        ) : (
          <div className="c-discussion-timeline">
            <p className="text-p-base">
              This is your latest mentoring session for this exercise. To
              continue the discussion, switch to{' '}
              <a className="font-semibold text-blue" href="mentor_discussions">
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
    )
  } else return null
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
