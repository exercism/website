// i18n-key-prefix: feedbackPanelMentoringDiscussion.feedbackPanelMentoringDiscussion
// i18n-namespace: components/editor/FeedbackPanel
import React from 'react'
import { useRequestQuery } from '@/hooks/request-query'
import { DiscussionPostProps } from '@/components/mentoring/discussion/DiscussionPost'
import { FeedbackPanelProps } from '../FeedbackPanel'
import { FeedbackDetail } from '../FeedbackDetail'
import { PendingMentoringRequest, ReadonlyDiscussionPostView } from '.'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation('components/editor/FeedbackPanel')

  const { data, status } = useRequestQuery<{ items: DiscussionPostProps[] }>(
    [`posts-discussion-${discussion?.uuid}`],
    { endpoint: discussion?.links.posts, options: { enabled: !!discussion } }
  )
  if (discussion) {
    return (
      <FeedbackDetail open={open} summary={t('feedbackPanel.codeReview')}>
        {status === 'pending' ? (
          <div>
            {t(
              'feedbackPanelMentoringDiscussion.feedbackPanelMentoringDiscussion.loading'
            )}
          </div>
        ) : (
          <div className="c-discussion-timeline">
            <p className="text-p-base">
              <Trans
                i18nKey="feedbackPanelMentoringDiscussion.feedbackPanelMentoringDiscussion.latestCodeReviewSessionDescription"
                ns="components/editor/FeedbackPanel"
                components={{
                  link: (
                    <a
                      href="mentor_discussions"
                      className="font-semibold text-blue"
                    />
                  ),
                }}
              />
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
      <FeedbackDetail
        open={open}
        summary={t('feedbackPanel.codeReviewPending')}
      >
        <PendingMentoringRequest mentoringRequestLink={mentoringRequestLink} />
      </FeedbackDetail>
    )
  } else return null
}
