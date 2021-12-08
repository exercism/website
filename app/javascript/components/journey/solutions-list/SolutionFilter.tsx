import React, { useState, useEffect, useRef } from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { ExerciseStatus, ExerciseStatusSelect } from './ExerciseStatusSelect'
import { MentoringStatus, MentoringStatusSelect } from './MentoringStatusSelect'

export const SolutionFilter = ({
  status,
  setStatus,
  mentoringStatus,
  setMentoringStatus,
}: {
  status: ExerciseStatus
  setStatus: (status: ExerciseStatus) => void
  mentoringStatus: MentoringStatus
  setMentoringStatus: (status: MentoringStatus) => void
}): JSX.Element => {
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
        ref={dialogRef}
        tabIndex={-1}
        role="dialog"
        aria-label="A series of options to filter Exercism tracks"
        {...(expanded ? {} : { hidden: true })}
      >
        <div className="lg-container container">
          <ExerciseStatusSelect value={status} setValue={setStatus} />
          <MentoringStatusSelect
            value={mentoringStatus}
            setValue={setMentoringStatus}
          />
        </div>
      </div>
    </>
  )
}
