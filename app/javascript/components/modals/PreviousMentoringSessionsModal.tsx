import React from 'react'
import { fromNow } from '../../utils/time'
import {
  Avatar,
  GraphicalIcon,
  Pagination,
  TrackIcon,
  ExerciseIcon,
} from '../common'
import { Modal, ModalProps } from './Modal'
import { Student } from '../mentoring/Session'
import pluralize from 'pluralize'
import { FavoriteButton } from '../mentoring/session/FavoriteButton'
import { useList } from '../../hooks/use-list'
import { useIsMounted } from 'use-is-mounted'
import { PaginatedResult, MentorDiscussion } from '../types'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'

const DEFAULT_ERROR = new Error('Unable to load discussions')

export const PreviousMentoringSessionsModal = ({
  onClose,
  student,
  ...props
}: Omit<ModalProps, 'className'> & { student: Student }): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage } = useList({
    endpoint: student.links.previousSessions,
  })
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<
    PaginatedResult<readonly MentorDiscussion[]>,
    Error | Response
  >([request.endpoint, request.query], request, isMountedRef)

  const DiscussionLink = ({ discussion }: { discussion: MentorDiscussion }) => {
    return (
      <a
        href={discussion.links.self}
        key={discussion.id}
        className="discussion"
      >
        <TrackIcon
          iconUrl={discussion.track.iconUrl}
          title={discussion.track.title}
        />
        <ExerciseIcon
          iconUrl={discussion.exercise.iconUrl}
          title={discussion.exercise.title}
          className="exercise-icon"
        />
        <div className="exercise-title">{discussion.exercise.title}</div>
        <div className="num-comments">
          <GraphicalIcon icon="comment" />
          {discussion.postsCount}
        </div>
        <div className="num-iterations">
          <GraphicalIcon icon="iteration" />
          {discussion.iterationsCount}
        </div>
        <time dateTime={discussion.createdAt}>
          {fromNow(discussion.createdAt)}
        </time>
        <GraphicalIcon icon="chevron-right" className="action-icon" />
      </a>
    )
  }

  return (
    <Modal {...props} onClose={onClose} className="m-mentoring-sessions">
      <header>
        <strong>
          You have {student.numPreviousSessions} previous{' '}
          {pluralize('discussion', student.numPreviousSessions)}
        </strong>
        with
        <Avatar src={student.avatarUrl} handle={student.handle} />
        <div className="student-name">{student.handle}</div>
        <FavoriteButton
          isFavorite={student.isFavorite}
          endpoint={student.links.favorite}
        />
      </header>
      <div className="discussions">
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          <ResultsZone isFetching={isFetching}>
            {resolvedData ? (
              <React.Fragment>
                {resolvedData.results.map((discussion: MentorDiscussion) => (
                  <DiscussionLink discussion={discussion} key={discussion.id} />
                ))}
                <Pagination
                  disabled={latestData === undefined}
                  current={request.query.page}
                  total={resolvedData.meta.totalPages}
                  setPage={setPage}
                />
              </React.Fragment>
            ) : null}
          </ResultsZone>
        </FetchingBoundary>
      </div>
    </Modal>
  )
}
