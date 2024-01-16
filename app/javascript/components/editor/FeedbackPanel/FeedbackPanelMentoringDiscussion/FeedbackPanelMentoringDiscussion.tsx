import React from 'react'
import { useRequestQuery } from '@/hooks/request-query'
import { DiscussionPostProps } from '@/components/mentoring/discussion/DiscussionPost'
import { FeedbackPanelProps } from '../FeedbackPanel'
import { FeedbackDetail } from '../FeedbackDetail'
import { PendingMentoringRequest, ReadonlyDiscussionPostView } from '.'

export function MentoringDiscussion({
  discussion,
  requestedMentoring,
  mentoringRequestLink,
  open,
}: Pick<
  FeedbackPanelProps,
  'discussion' | 'requestedMentoring' | 'mentoringRequestLink'
> & {
  open?: boolean
}): JSX.Element | null {
  const { data, status } = useRequestQuery<{ items: DiscussionPostProps[] }>(
    [`posts-discussion-${discussion?.uuid}`],
    { endpoint: discussion?.links.posts, options: { enabled: !!discussion } }
  )
  if (discussion) {
    return (
      <FeedbackDetail open={open} summary="Code Review">
        {status === 'loading' ? (
          <div>Loading…</div>
        ) : (
          <div className="c-discussion-timeline">
            <p className="text-p-base">
              This is your latest code review session for this exercise. To
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
  } else if (requestedMentoring) {
    return (
      <FeedbackDetail open={open} summary="Code Review (Pending)">
        <PendingMentoringRequest mentoringRequestLink={mentoringRequestLink} />
      </FeedbackDetail>
    )
  } else return null
}
