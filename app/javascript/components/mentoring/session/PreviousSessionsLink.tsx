import React, { useState, useCallback } from 'react'
import { Icon } from '../../common/Icon'
import pluralize from 'pluralize'
import { PreviousMentoringSessionsModal } from '../../modals/PreviousMentoringSessionsModal'
import { PaginatedResult, MentorDiscussion, Student } from '../../types'
import { useList } from '../../../hooks/use-list'
import { Request } from '../../../hooks/request-query'
import { FetchingBoundary } from '../../FetchingBoundary'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { PaginatedQueryResult } from 'react-query'

const DEFAULT_ERROR = new Error('Unable to load previous discussions')

export const PreviousSessionsLink = ({
  endpoint,
  student,
  setStudent,
}: {
  endpoint: string
  student: Student
  setStudent: (student: Student) => void
  discussion?: MentorDiscussion
}): JSX.Element | null => {
  const { request, setPage } = useList({ endpoint: endpoint })
  const query = usePaginatedRequestQuery<
    PaginatedResult<readonly MentorDiscussion[]>
  >([request.endpoint, request.query], request)

  return (
    <React.Fragment>
      <FetchingBoundary
        status={query.status}
        error={query.error}
        defaultError={DEFAULT_ERROR}
      >
        {query.resolvedData ? (
          <Component
            student={student}
            setStudent={setStudent}
            query={query}
            request={request}
            setPage={setPage}
          />
        ) : null}
      </FetchingBoundary>
    </React.Fragment>
  )
}

const Component = ({
  student,
  setStudent,
  query,
  request,
  setPage,
}: {
  student: Student
  setStudent: (student: Student) => void
  query: PaginatedQueryResult<PaginatedResult<readonly MentorDiscussion[]>>
  request: Request
  setPage: (page: number) => void
}): JSX.Element | null => {
  const [open, setOpen] = useState(false)

  const handleModalOpen = useCallback(() => {
    setOpen(true)
  }, [])

  if (query.resolvedData === undefined) {
    return null
  }

  const previousCount = query.resolvedData.meta.totalCount

  if (previousCount < 1) {
    return null
  }

  return (
    <React.Fragment>
      <button
        type="button"
        className="previous-sessions"
        onClick={handleModalOpen}
      >
        See {previousCount} previous {pluralize('session', previousCount)}
        <Icon icon="modal" alt="Opens in modal" />
      </button>
      <PreviousMentoringSessionsModal
        open={open}
        student={student}
        setStudent={setStudent}
        onClose={() => setOpen(false)}
        query={query}
        page={request.query?.page || 1}
        setPage={setPage}
      />
    </React.Fragment>
  )
}
