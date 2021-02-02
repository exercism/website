import React, { useState, useCallback } from 'react'
import { Accordion } from '../../common/Accordion'
import { MentorNotes } from './MentorNotes'
import {
  MentorSolution as MentorSolutionProps,
  Track,
  Exercise,
} from '../Discussion'
import { MentorSolution } from './MentorSolution'

export const Guidance = ({
  notes,
  mentorSolution,
  track,
  exercise,
}: {
  notes: string
  mentorSolution: MentorSolutionProps
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
      setAccordionState(
        accordionState.map((state) => {
          const isOpen = id === state.id && !state.isOpen
          return {
            id: state.id,
            isOpen: isOpen,
          }
        })
      )
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
      <Accordion id="notes" isOpen={isOpen('notes')} onClick={handleClick}>
        <Accordion.Header>Mentor notes</Accordion.Header>
        <Accordion.Panel>
          <MentorNotes notes={notes} />
        </Accordion.Panel>
      </Accordion>
      <Accordion
        id="solution"
        isOpen={isOpen('solution')}
        onClick={handleClick}
      >
        <Accordion.Header>How you solved the exercise</Accordion.Header>
        <Accordion.Panel>
          <MentorSolution
            solution={mentorSolution}
            track={track}
            exercise={exercise}
          />
        </Accordion.Panel>
      </Accordion>
      <Accordion
        id="feedback"
        isOpen={isOpen('feedback')}
        onClick={handleClick}
      >
        <Accordion.Header>Automated feedback</Accordion.Header>
        <Accordion.Panel>
          <p>Feedback here</p>
        </Accordion.Panel>
      </Accordion>
    </>
  )
}
