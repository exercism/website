import React, { useState, useCallback } from 'react'
import { Accordion } from '../../common/Accordion'
import { MentorNotes } from './MentorNotes'
import {
  CommunitySolution as CommunitySolutionProps,
  GuidanceLinks,
  MentoringSessionExemplarFile,
} from '../../types'
import { GraphicalIcon } from '../../common'
import CommunitySolution from '@/components/common/CommunitySolution'
import { useHighlighting } from '../../../utils/highlight'
import { ExemplarFilesList } from './guidance/ExemplarFilesList'
import { SessionGuidance } from '../Session'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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

export type Props = {
  guidance: SessionGuidance
  mentorSolution?: CommunitySolutionProps
  exemplarFiles: readonly MentoringSessionExemplarFile[]
  links: GuidanceLinks
  language: string
  feedback?: any
}

export const Guidance = ({
  guidance,
  mentorSolution,
  exemplarFiles,
  links,
  language,
  feedback = false,
}: Props): JSX.Element => {
  const { t } = useAppTranslation('session-batch-2')
  const ref = useHighlighting<HTMLDivElement>()
  const [accordionState, setAccordionState] = useState([
    {
      id: 'exemplar-files',
      isOpen: exemplarFiles.length !== 0,
    },
    {
      id: 'exercise-guidance',
      isOpen: exemplarFiles.length === 0,
    },
    {
      id: 'track-guidance',
      isOpen: false,
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
    <div ref={ref}>
      {exemplarFiles.length !== 0 ? (
        <Accordion
          id="exemplar-files"
          isOpen={isOpen('exemplar-files')}
          onClick={handleClick}
        >
          <AccordionHeader
            isOpen={isOpen('exemplar-files')}
            title={t(
              'components.mentoring.session.guidance.theExemplarSolution'
            )}
          />
          <Accordion.Panel>
            <div className="c-textual-content --small">
              <p>
                {t('components.mentoring.session.guidance.tryAndGuideStudent')}
              </p>
              <ExemplarFilesList files={exemplarFiles} language={language} />
            </div>
          </Accordion.Panel>
        </Accordion>
      ) : null}
      <Accordion
        id="exercise-guidance"
        isOpen={isOpen('exercise-guidance')}
        onClick={handleClick}
      >
        <AccordionHeader
          isOpen={isOpen('exercise-guidance')}
          title={t('components.mentoring.session.guidance.exerciseNotes')}
        />
        <Accordion.Panel>
          <MentorNotes
            notes={guidance.exercise}
            guidanceType="exercise"
            improveUrl={links.improveExerciseGuidance}
          />
        </Accordion.Panel>
      </Accordion>
      <Accordion
        id="track-guidance"
        isOpen={isOpen('track-guidance')}
        onClick={handleClick}
      >
        <AccordionHeader
          isOpen={isOpen('track-guidance')}
          title={t('components.mentoring.session.guidance.trackNotes')}
        />
        <Accordion.Panel>
          <MentorNotes
            notes={guidance.track}
            guidanceType="track"
            improveUrl={links.improveTrackGuidance}
          />
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
            title={t(
              'components.mentoring.session.guidance.howYouSolvedExercise'
            )}
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
            title={t('components.mentoring.session.guidance.automatedFeedback')}
          />
          <Accordion.Panel>
            <p>{t('components.mentoring.session.guidance.feedbackHere')}</p>
          </Accordion.Panel>
        </Accordion>
      ) : null}
    </div>
  )
}
