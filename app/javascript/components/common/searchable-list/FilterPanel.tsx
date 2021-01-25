import React, { useState, useEffect, useRef, useCallback } from 'react'
import { FilterList } from './FilterList'
import { GraphicalIcon } from '../GraphicalIcon'
import { FilterCategory, FilterValue } from '../SearchableList'

export const FilterPanel = ({
  value = {},
  categories,
  setFilter,
}: {
  value?: FilterValue
  categories: FilterCategory[]
  setFilter: (value: FilterValue) => void
}): JSX.Element => {
  const [expanded, setExpanded] = useState(false)
  const [selected, setSelected] = useState(value)
  const [hasExpandedEver, markAsExpanded] = useState(false)

  const dialogRef = useRef<HTMLDivElement>(null)
  const filterButtonRef = useRef<HTMLButtonElement>(null)

  useEffect(() => {
    if (!expanded || !dialogRef.current) {
      return
    }

    dialogRef.current.focus()
    markAsExpanded(true)
  }, [expanded])

  useEffect(() => {
    if (!hasExpandedEver || !filterButtonRef.current) {
      return
    }
    filterButtonRef.current.focus()
  }, [hasExpandedEver])

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

  const handleSubmit = useCallback(() => {
    setFilter(selected)
    setExpanded(false)
  }, [selected, setFilter])

  const handleClose = useCallback(() => {
    setExpanded(false)
  }, [])

  return (
    <>
      <button
        ref={filterButtonRef}
        onClick={() => setExpanded(true)}
        className="--filter-btn"
        aria-haspopup="true"
        aria-expanded={expanded}
      >
        Filter by
        <GraphicalIcon icon="chevron-down" />
      </button>
      <div
        ref={dialogRef}
        tabIndex={-1}
        role="dialog"
        aria-label="A series of checkboxes for filtering"
        className="--tag-option-list"
        {...(expanded ? {} : { hidden: true })}
      >
        <div className="lg-container container">
          <FilterList
            value={selected}
            setValue={setSelected}
            categories={categories}
          />
          <footer className="--buttons">
            <button
              type="button"
              className="--apply-btn"
              onClick={handleSubmit}
            >
              Apply
            </button>
            <button type="button" className="--close-btn" onClick={handleClose}>
              Close
            </button>
          </footer>
        </div>
      </div>
    </>
  )
}
