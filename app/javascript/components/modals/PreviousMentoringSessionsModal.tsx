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
import pluralize from 'pluralize'
import {
  FavoritableStudent,
  FavoriteButton,
} from '../mentoring/session/FavoriteButton'
import { MentorDiscussion, Student, PaginatedResult } from '../types'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { PaginatedQueryResult } from 'react-query'

const DEFAULT_ERROR = new Error('Unable to load discussions')

export const PreviousMentoringSessionsModal = ({
  onClose,
  student,
  setStudent,
  query,
  previousCount,
  page,
  setPage,
  ...props
}: Omit<ModalProps, 'className'> & {
  student: Student
  setStudent: (student: Student) => void
  query: PaginatedQueryResult<PaginatedResult<readonly MentorDiscussion[]>>
  previousCount: number
  page: number
  setPage: (page: number) => void
}): JSX.Element => {
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

  return (
    <Modal {...props} onClose={onClose} className="m-mentoring-sessions">
      <header>
        <strong>
          You have {previousCount} previous{' '}
          {pluralize('discussion', previousCount)}
        </strong>
        with
        <Avatar src={student.avatarUrl} handle={student.handle} />
        <div className="student-name">{student.handle}</div>
        {student.links.favorite ? (
          <FavoriteButton
            student={student as FavoritableStudent}
            onSuccess={(student) => setStudent(student)}
          />
        ) : null}
      </header>
      <div className="discussions">
        <ResultsZone isFetching={query.isFetching}>
          <FetchingBoundary
            status={query.status}
            error={query.error}
            defaultError={DEFAULT_ERROR}
          >
            {query.resolvedData ? (
              <React.Fragment>
                {query.resolvedData.results.map(
                  (discussion: MentorDiscussion) => (
                    <DiscussionLink
                      discussion={discussion}
                      key={discussion.uuid}
                    />
                  )
                )}
                <Pagination
                  disabled={query.latestData === undefined}
                  current={page}
                  total={query.resolvedData.meta.totalPages}
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
