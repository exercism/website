import React, { useCallback } from 'react'
import { Modal } from '../Modal'
import { ExerciseIcon } from '../../common'
import { ConceptProgression } from './exercise-completed-modal/ConceptProgression'
import { Unlocks } from './exercise-completed-modal/Unlocks'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { redirectTo } from '../../../utils/redirect-to'
import pluralize from 'pluralize'

export const ExerciseCompletedModal = ({
  open,
  completion,
  ...props
}: {
  open: boolean
  completion: ExerciseCompletion
}): JSX.Element => {
  const {
    track,
    exercise,
    conceptProgressions,
    unlockedExercises,
    unlockedConcepts,
  } = completion

  const handleContinue = useCallback(() => {
    redirectTo(exercise.links.self)
  }, [exercise.links.self])

  const content =
    exercise.type == 'concept' ? (
      <>
        <h3>
          Awesome work. You’re one step closer to learning {track.title} 🚀
        </h3>
        {conceptProgressions.length > 0 ? (
          <div className="info">
            You’ve learnt{' '}
            <strong>
              {conceptProgressions.length}{' '}
              {pluralize('concept', conceptProgressions.length)}
            </strong>
            {unlockedExercises.length > 0
              ? ` and unlocked ${unlockedExercises.length} ${pluralize(
                  'exercise',
                  unlockedExercises.length
                )}`
              : null}{' '}
            by completing this exercise.
          </div>
        ) : null}
        <div className="progressed-concepts">
          {conceptProgressions.map((progression) => (
            <ConceptProgression key={progression.name} {...progression} />
          ))}
        </div>
        {unlockedExercises.length !== 0 || unlockedConcepts.length !== 0 ? (
          <Unlocks
            unlockedExercises={unlockedExercises}
            unlockedConcepts={unlockedConcepts}
          />
        ) : null}

        <div className="btns">
          {track.numConcepts > 0 ? (
            <a href={track.links.concepts} className="btn-primary btn-m">
              Show me more concepts
            </a>
          ) : null}
          <button onClick={handleContinue} className="btn">
            Return to the exercise
          </button>
        </div>
      </>
    ) : (
      <>
        <h3>
          Awesome work. You’re one step closer to mastering {track.title} 🚀
        </h3>
        {conceptProgressions.length > 0 ? (
          <>
            <div className="info">
              You’ve progressed with{' '}
              <strong>
                {conceptProgressions.length}{' '}
                {pluralize('concept', conceptProgressions.length)}
              </strong>{' '}
              by completing this exercise.
            </div>
            <div className="progressed-concepts">
              {conceptProgressions.map((progression) => (
                <ConceptProgression key={progression.name} {...progression} />
              ))}
            </div>
          </>
        ) : (
          <div className="info">
            Once you&apos;ve practiced some more {track.title}, come back to
            this exercise and see if you can make it even better.
          </div>
        )}

        <div className="btns">
          <a href={track.links.exercises} className="btn-primary btn-m">
            Show me more exercises
          </a>
          <button onClick={handleContinue} className="btn">
            Return to the exercise
          </button>
        </div>
      </>
    )
  return (
    <Modal
      cover={true}
      open={open}
      className="m-completed-exercise c-completed-exercise-progress"
      onClose={() => null}
      {...props}
    >
      <ExerciseIcon iconUrl={exercise.iconUrl} />
      <h2>You&apos;ve completed {exercise.title}!</h2>
      {content}
    </Modal>
  )
}
