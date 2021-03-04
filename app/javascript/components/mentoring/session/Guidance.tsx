import React, { useState, useCallback } from 'react'
import { Details } from '../../common/Details'
import { MentorNotes } from './MentorNotes'
import {
  MentorSolution as MentorSolutionProps,
  Track,
  Exercise,
} from '../Session'
import { MentorSolution } from './MentorSolution'
import { GraphicalIcon } from '../../common'

const Summary = ({
  title,
  onClick,
}: {
  title: string
  onClick: () => void
}) => {
  return (
    <Details.Summary onClick={onClick}>
      <GraphicalIcon icon="minus-circle" className="--closed-icon" />
      <GraphicalIcon icon="plus-circle" className="--open-icon" />
      <div className="--title">{title}</div>
    </Details.Summary>
  )
}

export const Guidance = ({
  notes,
  mentorSolution,
  track,
  exercise,
}: {
  notes: string
  mentorSolution?: MentorSolutionProps
  track: Track
  exercise: Exercise
}): JSX.Element => {
  const [accordionState, setAccordionState] = useState([
    {
      id: 'notes',
      isOpen: true,
    },
    {
      id: 'solution',
      isOpen: false,
    },
    {
      id: 'feedback',
      isOpen: false,
    },
  ])

  const handleClick = useCallback(
    (id: string) => {
      setTimeout(() => {
        setAccordionState(
          accordionState.map((state) => {
            const isOpen = id === state.id && !state.isOpen
            return {
              id: state.id,
              isOpen: isOpen,
            }
          })
        )
      }, 0)
    },
    [accordionState]
  )

  const isOpen = useCallback(
    (id: string) => {
      const state = accordionState.find((state) => state.id === id)

      if (!state) {
        throw new Error('Accordion id not found')
      }

      return state.isOpen
    },
    [accordionState]
  )

  return (
    <>
      <Details isOpen={isOpen('notes')} label="Collapsable mentor notes">
        <Summary
          title="Mentor notes"
          onClick={() => {
            handleClick('notes')
          }}
        />
        <MentorNotes notes={notes} />
      </Details>
      {mentorSolution ? (
        <Details
          isOpen={isOpen('solution')}
          label="Collapsable information on how you solved the exercise"
        >
          <Summary
            title="How you solved the exercise"
            onClick={() => {
              handleClick('solution')
            }}
          />
          <MentorSolution
            solution={mentorSolution}
            track={track}
            exercise={exercise}
          />
        </Details>
      ) : null}
      <Details
        isOpen={isOpen('feedback')}
        label="Collapsable information on automated feedback"
      >
        <Summary
          title="Automated feedback"
          onClick={() => {
            handleClick('feedback')
          }}
        />
        <p>Feedback here</p>
      </Details>
    </>
  )
}
