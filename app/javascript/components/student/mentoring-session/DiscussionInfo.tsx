import React from 'react'
import { DiscussionPostList } from '../../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../../mentoring/discussion/NewMessageAlert'
import { PostsWrapper } from '../../mentoring/discussion/PostsContext'
import { MentorInfo } from './MentorInfo'
import { MentorDiscussion, Iteration } from '../../types'
import { Mentor } from '../MentoringSession'
import { GraphicalIcon } from '../../common'
import { FinishButton } from './FinishButton'
import { QueryStatus } from 'react-query'
import { DiscussionLinks } from './DiscussionActions'

export const DiscussionInfo = ({
  discussion,
  mentor,
  userHandle,
  iterations,
  onIterationScroll,
  links,
  status,
}: {
  discussion: MentorDiscussion
  mentor: Mentor
  userHandle: string
  iterations: readonly Iteration[]
  onIterationScroll: (iteration: Iteration) => void
  links: DiscussionLinks
  status: QueryStatus
}): JSX.Element => {
  return (
    <PostsWrapper discussion={discussion}>
      <div id="panel-discussion">
        <MentorInfo mentor={mentor} />
        <div className="discussion">
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
