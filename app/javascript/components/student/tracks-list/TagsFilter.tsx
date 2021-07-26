import React, { useState, useEffect, useRef, useCallback } from 'react'
import { TagOptionList } from './TagOptionList'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import pluralize from 'pluralize'
import { TagOption } from '../TracksList'

export const TagsFilter = ({
  options,
  setTags,
  value,
  numTracks,
}: {
  options: readonly TagOption[]
  setTags: (tags: string[]) => void
  value: string[]
  numTracks: number
}): JSX.Element => {
  const [expanded, setExpanded] = useState(false)
  const [selectedTags, setSelectedTags] = useState<string[]>(value)
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

  useEffect(() => {
    setSelectedTags(value)
  }, [value])

  const handleReset = useCallback(
    (e) => {
      e.preventDefault()

      setSelectedTags([])
      setTags([])
      setExpanded(false)
    },
    [setTags]
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
        ref={dialogRef}
        tabIndex={-1}
        role="dialog"
        aria-label="A series of checkboxes to filter Exercism tracks"
        className="--tag-option-list"
        {...(expanded ? {} : { hidden: true })}
      >
        <div className="lg-container container">
          <TagOptionList
            selectedTags={selectedTags}
            options={options}
            setSelectedTags={setSelectedTags}
            onSubmit={() => {
              setTags(selectedTags)
              setExpanded(false)
            }}
            onClose={() => setExpanded(false)}
          />
        </div>
      </div>
      <div className="--state">
        <p>
          Showing {value === undefined || value.length == 0 ? 'all' : ''}{' '}
          {numTracks} {pluralize('track', numTracks)}
        </p>
        {value !== undefined && value.length > 0 ? (
          <button onClick={handleReset} className="--reset-btn">
            <GraphicalIcon icon="reset" />
            Reset filters
          </button>
        ) : null}
      </div>
    </>
  )
}
