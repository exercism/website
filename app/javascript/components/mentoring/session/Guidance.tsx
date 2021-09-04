import React, { useState, useCallback } from 'react'
import { Accordion } from '../../common/Accordion'
import { MentorNotes } from './MentorNotes'
import { CommunitySolution as CommunitySolutionProps } from '../../types'
import { CommunitySolution, GraphicalIcon } from '../../common'

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

type Links = {
  improveNotes: string
}

export const Guidance = ({
  notes,
  mentorSolution,
  exemplarSolution,
  links,
  feedback = false,
}: {
  notes: string
  mentorSolution?: CommunitySolutionProps
  exemplarSolution: string
  links: Links
  feedback?: any
}): JSX.Element => {
  console.log(exemplarSolution)
  const [accordionState, setAccordionState] = useState([
    {
      id: 'exemplar-solution',
      isOpen: exemplarSolution != null,
    },
    {
      id: 'notes',
      isOpen: exemplarSolution == null,
    },
    {
      id: 'mentor-solution',
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
      {exemplarSolution ? (
        <Accordion
          id="exemplar-solution"
          isOpen={isOpen('exemplar-solution')}
          onClick={handleClick}
        >
          <AccordionHeader
            isOpen={isOpen('exemplar-solution')}
            title="The exemplar solution"
          />
          <Accordion.Panel>
            <div className="c-textual-content --small">
              <p>
                Try and guide the student towards this solution. It is the best
                place for them to reach at this point during the Track.
              </p>
              <pre className="overflow-auto">
                <code
                  dangerouslySetInnerHTML={{ __html: exemplarSolution }}
                ></code>
              </pre>
            </div>
          </Accordion.Panel>
        </Accordion>
      ) : null}
      <Accordion id="notes" isOpen={isOpen('notes')} onClick={handleClick}>
        <AccordionHeader isOpen={isOpen('notes')} title="Mentor notes" />
        <Accordion.Panel>
          <MentorNotes notes={notes} improveUrl={links.improveNotes} />
        </Accordion.Panel>
      </Accordion>
      {mentorSolution ? (
        <Accordion
          id="mentor-solution"
          isOpen={isOpen('mentor-solution')}
          onClick={handleClick}
        >
          <AccordionHeader
            isOpen={isOpen('mentor-solution')}
            title="How you solved the exercise"
          />
          <Accordion.Panel>
            <CommunitySolution context="mentoring" solution={mentorSolution} />
          </Accordion.Panel>
        </Accordion>
      ) : null}
      {feedback ? (
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
      ) : null}
    </>
  )
}
