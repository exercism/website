import React, { useContext } from 'react'
import { Trans } from 'react-i18next'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import pluralize from 'pluralize'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { useList } from '@/hooks/use-list'
import { scrollToTop } from '@/utils/scroll-to-top'
import { ScreenSizeContext } from '../mentoring/session/ScreenSizeContext'
import {
  Avatar,
  GraphicalIcon,
  Pagination,
  TrackIcon,
  ExerciseIcon,
} from '@/components/common'
import {
  FavoriteButton,
  type FavoritableStudent,
} from '@/components/mentoring/session/FavoriteButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import { Modal, type ModalProps } from './Modal'
import type {
  PaginatedResult,
  MentorDiscussion,
  Student,
} from '@/components/types'
import { fromNow } from '@/utils/time'

export const PreviousMentoringSessionsModal = ({
  onClose,
  student,
  setStudent,
  ...props
}: Omit<ModalProps, 'className'> & {
  student: Student
  setStudent: (student: Student) => void
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/PreviousMentoringSessionsModal.tsx'
  )
  const { request, setPage } = useList({
    endpoint: student.links.previousSessions,
    options: {},
  })

  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<
    PaginatedResult<readonly MentorDiscussion[]>,
    Error | Response
  >([request.endpoint, request.query], request)

  const numPrevious = student.numDiscussionsWithMentor - 1
  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}

  if (isBelowLgWidth) {
    return (
      <Modal
        {...props}
        closeButton
        onClose={onClose}
        className="m-mentoring-sessions mobile"
      >
        <header>
          <Trans
            i18nKey="headerMobile"
            ns="components/modals/PreviousMentoringSessionsModal.tsx"
            count={numPrevious}
            values={{ count: numPrevious, studentHandle: student.handle }}
            components={{
              strong: <strong />,
            }}
          />
        </header>
        <div className="discussions">
          <ResultsZone isFetching={isFetching}>
            <FetchingBoundary
              status={status}
              error={error}
              defaultError={new Error('Unable to load discussions')}
            >
              {resolvedData ? (
                <>
                  {resolvedData.results.map((discussion: MentorDiscussion) => (
                    <MobileDiscussionLink
                      discussion={discussion}
                      key={discussion.uuid}
                    />
                  ))}
                  <Pagination
                    disabled={resolvedData === undefined}
                    current={request.query.page || 1}
                    total={resolvedData.meta.totalPages}
                    setPage={(p) => {
                      setPage(p)
                      scrollToTop()
                    }}
                  />
                </>
              ) : null}
            </FetchingBoundary>
          </ResultsZone>
        </div>
      </Modal>
    )
  }

  return (
    <Modal
      {...props}
      closeButton
      onClose={onClose}
      className="m-mentoring-sessions"
    >
      <header>
        <Trans
          i18nKey="header"
          ns="components/modals/PreviousMentoringSessionsModal.tsx"
          count={numPrevious}
          values={{ count: numPrevious, studentHandle: student.handle }}
          components={{
            strong: <strong />,
            avatar: <Avatar src={student.avatarUrl} handle={student.handle} />,
            name: <div className="student-name" />,
          }}
        />
        {student.links.favorite ? (
          <FavoriteButton
            student={student as FavoritableStudent}
            onSuccess={(student) => setStudent(student)}
          />
        ) : null}
      </header>
      <div className="discussions">
        <ResultsZone isFetching={isFetching}>
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={new Error('Unable to load discussions')}
          >
            {resolvedData ? (
              <>
                {resolvedData.results.map((discussion: MentorDiscussion) => (
                  <DiscussionLink
                    discussion={discussion}
                    key={discussion.uuid}
                  />
                ))}
                <Pagination
                  disabled={resolvedData === undefined}
                  current={request.query.page || 1}
                  total={resolvedData.meta.totalPages}
                  setPage={(p) => {
                    setPage(p)
                    scrollToTop()
                  }}
                />
              </>
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      </div>
    </Modal>
  )
}

function DiscussionLink({
  discussion,
}: {
  discussion: MentorDiscussion
}): JSX.Element {
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

function MobileDiscussionLink({
  discussion,
}: {
  discussion: MentorDiscussion
}): JSX.Element {
  return (
    <a
      href={discussion.links.self}
      key={discussion.uuid}
      className="discussion mobile"
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
      <div className="num-comments">
        <GraphicalIcon icon="comment" />
        {discussion.postsCount}
      </div>
      <div className="num-iterations">
        <GraphicalIcon icon="iteration" />
        {discussion.iterationsCount}
      </div>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
