import React, { useReducer, useEffect, useRef } from 'react'
import { MentorAgainStep } from './finished-wizard/MentorAgainStep'
import { FavoriteStep } from './finished-wizard/FavoriteStep'
import { FinishStep } from './finished-wizard/FinishStep'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { FavoritableStudent } from '../session/FavoriteButton'

type State = {
  student: FavoritableStudent
  step: ModalStep
}

export type ModalStep = 'mentorAgain' | 'favorite' | 'finish'

type Action =
  | {
      type: 'MENTOR_AGAIN'
      payload: { student: FavoritableStudent }
    }
  | {
      type: 'WONT_MENTOR_AGAIN'
      payload: { student: FavoritableStudent }
    }
  | { type: 'FAVORITED'; payload: { student: FavoritableStudent } }
  | { type: 'SKIP_FAVORITE' }
  | { type: 'RESET' }

type Props = {
  student: FavoritableStudent
  setStudent: (student: FavoritableStudent) => void
  defaultStep: ModalStep
  timelineContent: string
}

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'MENTOR_AGAIN':
      return {
        student: action.payload.student,
        step: 'favorite',
      }
    case 'WONT_MENTOR_AGAIN':
      return {
        student: action.payload.student,
        step: 'finish',
      }
    case 'FAVORITED':
      return {
        student: action.payload.student,
        step: 'finish',
      }
    case 'SKIP_FAVORITE':
      return { ...state, step: 'finish' }
    case 'RESET':
      return { ...state, step: 'mentorAgain' }
  }
}

export const FinishedWizard = ({
  student,
  setStudent,
  defaultStep,
  timelineContent,
}: Props): JSX.Element => {
  const finishedWizardRef = useRef<HTMLDivElement>(null)
  const [state, dispatch] = useReducer(reducer, {
    student: student,
    step: defaultStep,
  })

  useEffect(() => {
    if (!finishedWizardRef.current) {
      return
    }

    finishedWizardRef.current.scrollIntoView()
  }, [student])

  return (
    <div ref={finishedWizardRef} className="finished-wizard timeline-entry">
      <GraphicalIcon
        icon="completed-check-circle"
        className="timeline-marker"
      />
      <div className="--details timeline-content">
        <h3>{timelineContent}</h3>
        <div className="--step">
          {state.step === 'mentorAgain' ? (
            <MentorAgainStep
              student={state.student}
              onYes={(student) => {
                dispatch({
                  type: 'MENTOR_AGAIN',
                  payload: { student: student },
                })
              }}
              onNo={(student) => {
                dispatch({
                  type: 'WONT_MENTOR_AGAIN',
                  payload: { student: student },
                })
              }}
            />
          ) : state.step === 'favorite' ? (
            <FavoriteStep
              student={state.student}
              onFavorite={(student) => {
                dispatch({
                  type: 'FAVORITED',
                  payload: { student: student },
                })

                setStudent(student)
              }}
              onSkip={() => {
                dispatch({ type: 'SKIP_FAVORITE' })
              }}
            />
          ) : state.step === 'finish' ? (
            <FinishStep
              student={state.student}
              onReset={() => {
                dispatch({ type: 'RESET' })
              }}
            />
          ) : (
            <>Incorrect state: {state.step} </>
          )}
        </div>
      </div>
    </div>
  )
}
