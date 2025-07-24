import React from 'react'
import { UnlockedConcept } from './UnlockedConcept'
import { UnlockedExercise } from './UnlockedExercise'
import { Concept } from '../../CompleteExerciseModal'
import { GraphicalIcon } from '../../../common'
import { Exercise } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const Unlocks = ({
  unlockedConcepts,
  unlockedExercises,
}: {
  unlockedConcepts: Concept[]
  unlockedExercises: Exercise[]
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx'
  )

  return (
    <div className="unlocks" data-testid="unlocks">
      {unlockedConcepts.length > 0 && (
        <div className="unlocked-concepts">
          <h3>
            <Trans
              ns="components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx"
              i18nKey="unlocks.conceptsUnlocked"
              count={unlockedConcepts.length}
              values={{ count: unlockedConcepts.length }}
              components={{
                icon: <GraphicalIcon icon="concepts" />,
              }}
            />
          </h3>
          <div className="list">
            {unlockedConcepts.map((concept) => (
              <UnlockedConcept key={concept.name} {...concept} />
            ))}
          </div>
        </div>
      )}
      {unlockedExercises.length > 0 && (
        <div className="unlocked-exercises">
          <h3>
            <Trans
              ns="components/modals/complete-exercise-modal/exercise-completed-modal/Unlocks.tsx"
              i18nKey="unlocks.exercisesUnlocked"
              count={unlockedExercises.length}
              values={{ count: unlockedExercises.length }}
              components={{
                icon: <GraphicalIcon icon="exercises" />,
              }}
            />
          </h3>
          <div className="list">
            {unlockedExercises.map((exercise) => (
              <UnlockedExercise key={exercise.title} {...exercise} />
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
