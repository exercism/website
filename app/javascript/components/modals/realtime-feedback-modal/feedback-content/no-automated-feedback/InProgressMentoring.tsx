import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'
import { FeedbackContentProps } from '../../FeedbackContent'
import { GraphicalIcon, HandleWithFlair } from '@/components/common'
import pluralize from 'pluralize'

export function InProgressMentoring({
  onContinue,
  discussion,
  mentoringRequestLink,
}: {
  mentoringRequestLink: string
  onContinue: () => void
} & Pick<FeedbackContentProps, 'discussion'>): JSX.Element {
  return (
    <div className="flex flex-col items-start h-[170px] justify-between c-mentor-discussion-widget">
      {discussion ? (
        <>
          <h3 className="flex text-h6 items-center">
            You&apos;re being mentored by&nbsp;
            {
              <HandleWithFlair
                handle={discussion.mentor.handle}
                flair={discussion.mentor.flair}
                size="large"
              />
            }
          </h3>

          <div className="flex gap-12">
            {discussion.status === 'awaiting_student' ? (
              <div className="--turn">Your turn to respond</div>
            ) : null}
            <div className="--comments">
              <GraphicalIcon icon="comment" />
              {discussion.postsCount}&nbsp;
              {pluralize('comments', discussion.postsCount)}
            </div>
          </div>
        </>
      ) : (
        <h3 className="flex text-h5 items-center">
          You have an ongoing mentoring session.
        </h3>
      )}

      <div className="flex gap-12">
        <a className="btn-primary btn-s mr-auto" href={mentoringRequestLink}>
          Go to your discussion
        </a>
        <ContinueButton
          text="Continue to exercise"
          onClick={onContinue}
          className="btn-secondary"
        />
      </div>
    </div>
  )
}
