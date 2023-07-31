import React, { useCallback } from 'react'
import { fromNow } from '../../utils/time'
import {
  Avatar,
  GraphicalIcon,
  Pagination,
  TrackIcon,
  ExerciseIcon,
} from '../common'
import { Modal, ModalProps } from './Modal'
import pluralize from 'pluralize'
import {
  FavoritableStudent,
  FavoriteButton,
} from '../mentoring/session/FavoriteButton'
import { useList } from '../../hooks/use-list'
import { PaginatedResult, MentorDiscussion, Student } from '../types'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'

const DEFAULT_ERROR = new Error('Unable to load discussions')

export const PreviousMentoringSessionsModal = ({
  onClose,
  student,
  setStudent,
  ...props
}: Omit<ModalProps, 'className'> & {
  student: Student
  setStudent: (student: Student) => void
}): JSX.Element => {
  const { request, setPage } = useList({
    endpoint: student.links.previousSessions,
    options: {},
  })
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<
      PaginatedResult<readonly MentorDiscussion[]>,
      Error | Response
    >([request.endpoint, request.query], request)

  const numPrevious = student.numDiscussionsWithMentor - 1

  const DiscussionLink = ({ discussion }: { discussion: MentorDiscussion }) => {
    return (
      <a
        href={discussion.links.self}
        key={discussion.uuid}
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

  const handleFavorited = useCallback(
    (newStudent) => {
      setStudent({ ...student, isFavorited: newStudent.isFavorited })
    },
    [setStudent, student]
  )

  return (
    <Modal
      {...props}
      closeButton
      onClose={onClose}
      className="m-mentoring-sessions"
    >
      <header>
        <strong>
          You have {numPrevious} previous {pluralize('discussion', numPrevious)}
        </strong>
        with
        <Avatar src={student.avatarUrl} handle={student.handle} />
        <div className="student-name">{student.handle}</div>
        {student.links.favorite ? (
          <FavoriteButton
            student={student as FavoritableStudent}
            onSuccess={handleFavorited}
          />
        ) : null}
      </header>
      <div className="discussions">
        <ResultsZone isFetching={isFetching}>
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={DEFAULT_ERROR}
          >
            {resolvedData ? (
              <React.Fragment>
                {resolvedData.results.map((discussion: MentorDiscussion) => (
                  <DiscussionLink
                    discussion={discussion}
                    key={discussion.uuid}
                  />
                ))}
                <Pagination
                  disabled={latestData === undefined}
                  current={request.query.page}
                  total={resolvedData.meta.totalPages}
                  setPage={setPage}
                />
              </React.Fragment>
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      </div>
    </Modal>
  )
}
