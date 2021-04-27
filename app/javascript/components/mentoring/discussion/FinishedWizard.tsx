import React, { useReducer, useEffect, useRef } from 'react'
import { MentorAgainStep } from './finished-wizard/MentorAgainStep'
import { FavoriteStep } from './finished-wizard/FavoriteStep'
import { FinishStep } from './finished-wizard/FinishStep'
import { Student } from '../Session'
import { GraphicalIcon } from '../../common/GraphicalIcon'

type State = {
  student: Student
  step: ModalStep
}

export type ModalStep = 'mentorAgain' | 'favorite' | 'finish'

type Action =
  | {
      type: 'MENTOR_AGAIN'
      payload: { student: Student }
    }
  | {
      type: 'WONT_MENTOR_AGAIN'
      payload: { student: Student }
    }
  | { type: 'FAVORITED'; payload: { student: Student } }
  | { type: 'SKIP_FAVORITE' }
  | { type: 'RESET' }

type Props = {
  student: Student
  defaultStep: ModalStep
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

export const FinishedWizard = ({ student, defaultStep }: Props) => {
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
    <div ref={finishedWizardRef} className="finished-wizard">
      <GraphicalIcon icon="completed-check-circle" />
      <div className="--details">
        <h3>You&apos;ve finished your discussion with {student.handle}.</h3>
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
          ) : null}
          {state.step === 'favorite' ? (
            <FavoriteStep
              student={state.student}
              onFavorite={(student) => {
                dispatch({
                  type: 'FAVORITED',
                  payload: { student: student },
                })
              }}
              onSkip={() => {
                dispatch({ type: 'SKIP_FAVORITE' })
              }}
            />
          ) : null}
          {state.step === 'finish' ? (
            <FinishStep
              student={state.student}
              onReset={() => {
                dispatch({ type: 'RESET' })
              }}
            />
          ) : null}
        </div>
      </div>
    </div>
  )
}
