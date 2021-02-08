import React, { useReducer } from 'react'
import { MentorAgainStep } from './finished-wizard/MentorAgainStep'
import { FavoriteStep } from './finished-wizard/FavoriteStep'
import { FinishStep } from './finished-wizard/FinishStep'
import { Student, StudentMentorRelationship } from '../Discussion'

type State = {
  relationship: StudentMentorRelationship
  step: ModalStep
}

type ModalStep = 'mentorAgain' | 'favorite' | 'finish'

type Action =
  | {
      type: 'MENTOR_AGAIN'
      payload: { relationship: StudentMentorRelationship }
    }
  | {
      type: 'WONT_MENTOR_AGAIN'
      payload: { relationship: StudentMentorRelationship }
    }
  | { type: 'FAVORITED'; payload: { relationship: StudentMentorRelationship } }
  | { type: 'SKIP_FAVORITE' }
  | { type: 'RESET' }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'MENTOR_AGAIN':
      return {
        relationship: action.payload.relationship,
        step: 'favorite',
      }
    case 'WONT_MENTOR_AGAIN':
      return {
        relationship: action.payload.relationship,
        step: 'finish',
      }
    case 'FAVORITED':
      return {
        relationship: action.payload.relationship,
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
  relationship,
}: {
  student: Student
  relationship: StudentMentorRelationship
}): JSX.Element => {
  const [state, dispatch] = useReducer(reducer, {
    relationship: relationship,
    step: 'mentorAgain',
  })

  return (
    <div className="finished-wizard">
      <h1>You&apos;ve finished your discussion with {student.handle}.</h1>
      {state.step === 'mentorAgain' ? (
        <MentorAgainStep
          student={student}
          relationship={state.relationship}
          onYes={(relationship) => {
            dispatch({
              type: 'MENTOR_AGAIN',
              payload: { relationship: relationship },
            })
          }}
          onNo={(relationship) => {
            dispatch({
              type: 'WONT_MENTOR_AGAIN',
              payload: { relationship: relationship },
            })
          }}
        />
      ) : null}
      {state.step === 'favorite' ? (
        <FavoriteStep
          student={student}
          relationship={state.relationship}
          onFavorite={(relationship) => {
            dispatch({
              type: 'FAVORITED',
              payload: { relationship: relationship },
            })
          }}
          onSkip={() => {
            dispatch({ type: 'SKIP_FAVORITE' })
          }}
        />
      ) : null}
      {state.step === 'finish' ? (
        <FinishStep
          student={student}
          relationship={state.relationship}
          onReset={() => {
            dispatch({ type: 'RESET' })
          }}
        />
      ) : null}
    </div>
  )
}
