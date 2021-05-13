import React, { useState, useEffect, useRef } from 'react'
import { TagOptionList } from './TagOptionList'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import pluralize from 'pluralize'

export function TagsFilter({ options, setTags, value, numTracks }) {
  const [expanded, setExpanded] = useState(false)
  const [selectedTags, setSelectedTags] = useState([])
  const [hasExpandedEver, markAsExpanded] = useState(false)

  const dialogRef = useRef(null)
  const filterButtonRef = useRef(null)

  useEffect(() => {
    if (expanded) {
      dialogRef.current.focus()
      markAsExpanded(true)
    } else if (hasExpandedEver) {
      filterButtonRef.current.focus()
    }
  }, [expanded])

  useEffect(() => {
    if (!expanded) {
      return
    }

    const handleEscape = (e) => {
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

  function handleSubmit(e) {
    e.preventDefault()

    setTags(selectedTags)
    setExpanded(false)
  }

  function handleClose(e) {
    e.preventDefault()

    setExpanded(false)
  }

  function resetFilters(e) {
    e.preventDefault()

    setSelectedTags([])
    setTags([])
  }

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
        tabIndex="-1"
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
            onSubmit={handleSubmit}
            onClose={handleClose}
          />
        </div>
      </div>
      <div className="--state">
        <p>
          Showing {value === undefined || value.length == 0 ? 'all' : ''}{' '}
          {numTracks} {pluralize('track', numTracks)}
        </p>
        {value !== undefined && value.length > 0 ? (
          <button onClick={resetFilters} className="--reset-btn">
            <GraphicalIcon icon="reset" />
            Reset filters
          </button>
        ) : null}
      </div>
    </>
  )
}
