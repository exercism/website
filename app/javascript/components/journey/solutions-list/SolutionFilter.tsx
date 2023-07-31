import React, { useState, useEffect, useRef, useCallback } from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { ExerciseStatus, ExerciseStatusSelect } from './ExerciseStatusSelect'
import { HeadTestsStatus, HeadTestsStatusSelect } from './HeadTestsStatusSelect'
import { MentoringStatus, MentoringStatusSelect } from './MentoringStatusSelect'
import { SyncStatus, SyncStatusSelect } from './SyncStatusSelect'
import { TestsStatus, TestsStatusSelect } from './TestsStatusSelect'

export const SolutionFilter = ({
  request,
  onApply,
}: {
  request: any
  onApply: (
    status: ExerciseStatus,
    mentoringStatus: MentoringStatus,
    syncStatus: SyncStatus,
    testsStatus: TestsStatus,
    headTestsStatus: HeadTestsStatus
  ) => void
}): JSX.Element => {
  const [status, setStatus] = useState<ExerciseStatus>(request.query.status)
  const [mentoringStatus, setMentoringStatus] = useState<MentoringStatus>(
    request.query.mentoringStatus
  )
  const [syncStatus, setSyncStatus] = useState<SyncStatus>(
    request.query.syncStatus
  )
  const [testsStatus, setTestsStatus] = useState<TestsStatus>(
    request.query.testsStatus
  )
  const [headTestsStatus, setHeadTestsStatus] = useState<HeadTestsStatus>(
    request.query.headTestsStatus
  )

  const [expanded, setExpanded] = useState(false)
  const [hasExpandedEver, markAsExpanded] = useState(false)

  const dialogRef = useRef<HTMLDivElement>(null)
  const filterButtonRef = useRef<HTMLButtonElement>(null)

  useEffect(() => {
    if (expanded) {
      if (!dialogRef.current) {
        return
      }

      dialogRef.current.focus()
      markAsExpanded(true)
    } else if (hasExpandedEver) {
      if (!filterButtonRef.current) {
        return
      }

      filterButtonRef.current.focus()
    }
  }, [expanded, hasExpandedEver])

  useEffect(() => {
    if (!expanded) {
      return
    }

    const handleEscape = (e: KeyboardEvent) => {
      if (e.key !== 'Escape') {
        return
      }

      e.stopPropagation()
      setExpanded(false)
    }

    document.addEventListener('keyup', handleEscape)
    return () => {
      document.removeEventListener('keyup', handleEscape)
    }
  }, [expanded])

  const handleApply = useCallback(
    (e) => {
      e.preventDefault()
      onApply(status, mentoringStatus, syncStatus, testsStatus, headTestsStatus)
      setExpanded(false)
    },
    [
      setExpanded,
      status,
      mentoringStatus,
      syncStatus,
      testsStatus,
      headTestsStatus,
    ]
  )

  const handleClose = useCallback(
    (e) => {
      e.preventDefault()
      setExpanded(false)
    },
    [setExpanded]
  )

  return (
    <>
      <button
        ref={filterButtonRef}
        onClick={() => setExpanded(!expanded)}
        className="--filter-btn"
        aria-haspopup="true"
        aria-expanded={expanded}
      >
        <span className="hidden sm:block sm:mr-12">Filter by</span>
        <GraphicalIcon icon="chevron-down" />
      </button>
      <div
        className="filter-options"
        ref={dialogRef}
        tabIndex={-1}
        role="dialog"
        aria-label="A series of options to filter Exercism tracks"
        {...(expanded ? {} : { hidden: true })}
      >
        <div className="md-container container">
          <div className="options">
            <ExerciseStatusSelect value={status} setValue={setStatus} />
            <MentoringStatusSelect
              value={mentoringStatus}
              setValue={setMentoringStatus}
            />
            <SyncStatusSelect value={syncStatus} setValue={setSyncStatus} />
            <TestsStatusSelect value={testsStatus} setValue={setTestsStatus} />
            <HeadTestsStatusSelect
              value={headTestsStatus}
              setValue={setHeadTestsStatus}
            />
          </div>
          <footer className="buttons">
            <button className="btn-primary btn-m" onClick={handleApply}>
              Apply filters
            </button>
            <button className="btn-default btn-m" onClick={handleClose}>
              Close
            </button>
          </footer>
        </div>
      </div>
    </>
  )
}
