import React, { useState, useCallback } from 'react'
import { Accordion } from '../../common/Accordion'
import { MentorNotes } from './MentorNotes'
import { CommunitySolution as CommunitySolutionProps } from '../../types'
import { CommunitySolution, GraphicalIcon } from '../../common'
import {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../../types'

const AccordionHeader = ({
  isOpen,
  title,
}: {
  isOpen: boolean
  title: string
}) => {
  return (
    <Accordion.Header>
      {isOpen ? (
        <GraphicalIcon icon="minus-circle" />
      ) : (
        <GraphicalIcon icon="plus-circle" />
      )}
      <div className="--title">{title}</div>
    </Accordion.Header>
  )
}

export const Guidance = ({
  notes,
  mentorSolution,
  track,
  exercise,
}: {
  notes: string
  mentorSolution?: CommunitySolutionProps
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
        <AccordionHeader isOpen={isOpen('notes')} title="Mentor notes" />
        <Accordion.Panel>
          <MentorNotes notes={notes} />
        </Accordion.Panel>
      </Accordion>
      {mentorSolution ? (
        <Accordion
          id="solution"
          isOpen={isOpen('solution')}
          onClick={handleClick}
        >
          <AccordionHeader
            isOpen={isOpen('solution')}
            title="How you solved the exercise"
          />
          <Accordion.Panel>
            <CommunitySolution context="mentoring" solution={mentorSolution} />
          </Accordion.Panel>
        </Accordion>
      ) : null}
      <Accordion
        id="feedback"
        isOpen={isOpen('feedback')}
        onClick={handleClick}
      >
        <AccordionHeader
          isOpen={isOpen('feedback')}
          title="Automated feedback"
        />
        <Accordion.Panel>
          <p>Feedback here</p>
        </Accordion.Panel>
      </Accordion>
    </>
  )
}
