import React from 'react'
import { DiscussionPostList } from '../../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../../mentoring/discussion/NewMessageAlert'
import { PostsWrapper } from '../../mentoring/discussion/PostsContext'
import { MentorInfo } from './MentorInfo'
import {
  MentorDiscussion,
  Iteration,
  MentoringSessionDonation,
} from '../../types'
import { Mentor } from '../MentoringSession'
import { GraphicalIcon } from '../../common'
import { FinishButton } from './FinishButton'
import { QueryStatus } from 'react-query'
import { DiscussionActionsLinks } from './DiscussionActions'

export const DiscussionInfo = ({
  discussion,
  mentor,
  userHandle,
  iterations,
  onIterationScroll,
  links,
  status,
  donation,
}: {
  discussion: MentorDiscussion
  mentor: Mentor
  userHandle: string
  iterations: readonly Iteration[]
  onIterationScroll: (iteration: Iteration) => void
  links: DiscussionActionsLinks
  status: QueryStatus
  donation: MentoringSessionDonation
}): JSX.Element => {
  return (
    <PostsWrapper discussion={discussion}>
      <div id="panel-discussion">
        <MentorInfo mentor={mentor} />
        <div className="c-discussion-timeline">
          <DiscussionPostList
            iterations={iterations}
            userIsStudent={true}
            discussionUuid={discussion.uuid}
            userHandle={userHandle}
            onIterationScroll={onIterationScroll}
            status={status}
          />
          {discussion.status === 'mentor_finished' ? (
            <div className="student-review timeline-entry">
              <GraphicalIcon
                icon="completed-check-circle"
                className="timeline-marker"
              />
              <div className="--details timeline-content">
                <h3>{mentor.handle} ended this discussion.</h3>
                <p>
                  <strong>
                    It&apos;s time to review {mentor.handle}&apos;s mentoring
                  </strong>
                  You&apos;ll be able to leave feedback and share what you
                  thought of your experience.
                </p>
                <FinishButton
                  discussion={discussion}
                  links={links}
                  className="btn-primary btn-s"
                  donation={donation}
                >
                  Review &amp; finish discussion
                </FinishButton>
              </div>
            </div>
          ) : null}
        </div>
      </div>
      <section className="comment-section --comment">
        <NewMessageAlert />
        <AddDiscussionPost discussion={discussion} />
      </section>
    </PostsWrapper>
  )
}
