import React, { useCallback, useState } from 'react'
import { usePanel } from '@/hooks/use-panel'
import { Icon } from '@/components/common'

type Tags = Record<string, boolean>
export function ExerciseTagFilter({
  tags = MOCK_TAGS,
}: {
  tags?: Tags
}): JSX.Element {
  const [tagState, setTagState] = useState<Tags>(tags)

  const { buttonAttributes, panelAttributes, setOpen, open } = usePanel()

  const handleToggleTag = useCallback((tagName: string) => {
    setTagState((currentTags) => {
      return {
        ...currentTags,
        [tagName]: !currentTags[tagName],
      }
    })
  }, [])
  return (
    <div className="c-single-select mr-24">
      <button
        type="button"
        {...buttonAttributes}
        onClick={() => setOpen((o) => !o)}
      >
        <div className="value">Filter by tag</div>
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      {open ? (
        <div {...panelAttributes} className="--options flex flex-wrap gap-4">
          {Object.entries(tagState).map(([tagName, isActive], index) => {
            return (
              <Tag
                tagName={tagName}
                isActive={isActive}
                key={`${isActive}_${index}`}
                onClick={handleToggleTag}
              />
            )
          })}
        </div>
      ) : null}
    </div>
  )
}

const toggledOnStyle =
  'border-darkGreen text-everyoneLovesAGreen bg-[var(--backgroundColorConceptMastered)]'
const toggledOffStyle =
  'border-red text-red bg-[(var(--backgroundColorExerciseStatusTagLocked)]'
function Tag({
  tagName,
  isActive,
  onClick,
}: {
  tagName: string
  isActive: boolean
  onClick: (tagName: string) => void
}) {
  return (
    <button
      onClick={() => onClick(tagName)}
      className={`c-tag px-12 py-4 flex ${
        isActive ? toggledOnStyle : toggledOffStyle
      }`}
    >
      {tagName}
    </button>
  )
}

const MOCK_TAGS = {
  Recursion: true,
  'Functional Programming': true,
  'If Statements': true,
  'Looping Structures': true,
  'Data Structures': true,
  'Object-Oriented Programming': true,
  Algorithms: true,
  'String Manipulation': true,
  Arrays: true,
  'Hash Maps': true,
  Graphs: true,
  Trees: true,
  'Queues and Stacks': true,
  Concurrency: true,
  'Memory Management': true,
  'Database Operations': true,
  'Web Development': true,
  'API Integration': true,
  'File I/O': true,
  'Error Handling': true,
  Debugging: true,
  'Testing and TDD': true,
  'Design Patterns': true,
  Networking: true,
  Security: true,
  'Regular Expressions': true,
  'Performance Optimization': true,
}
