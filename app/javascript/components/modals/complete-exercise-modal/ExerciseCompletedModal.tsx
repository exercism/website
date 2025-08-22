import React, { useCallback, useMemo } from 'react'
import { Trans } from 'react-i18next'
import { Modal } from '../Modal'
import { ExerciseIcon } from '../../common'
import { ConceptProgression } from './exercise-completed-modal/ConceptProgression'
import { Unlocks } from './exercise-completed-modal/Unlocks'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { redirectTo } from '../../../utils/redirect-to'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Props = {
  open: boolean
  completion: ExerciseCompletion
}

export const ExerciseCompletedModal: React.FC<Props> = ({
  open,
  completion,
  ...props
}) => {
  const { t } = useAppTranslation('components/modals/complete-exercise-modal')
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

  const conceptCount = conceptProgressions.length
  const unlockedExercisesCount = unlockedExercises.length

  const conceptInfoKey = useMemo(() => {
    if (exercise.type === 'concept') {
      if (conceptCount > 0) {
        if (unlockedExercisesCount > 0) {
          if (conceptCount === 1 && unlockedExercisesCount === 1)
            return 'exerciseCompletedModal.concept.info_1_1'
          if (conceptCount === 1 && unlockedExercisesCount > 1)
            return 'exerciseCompletedModal.concept.info_1_many'
          if (conceptCount > 1 && unlockedExercisesCount === 1)
            return 'exerciseCompletedModal.concept.info_many_1'
          return 'exerciseCompletedModal.concept.info_many_many'
        }

        return conceptCount === 1
          ? 'exerciseCompletedModal.concept.info_1'
          : 'exerciseCompletedModal.concept.info_many'
      }
      return null
    } else {
      if (conceptCount > 0) {
        return conceptCount === 1
          ? 'exerciseCompletedModal.practice.info_1'
          : 'exerciseCompletedModal.practice.info_many'
      }
      return 'exerciseCompletedModal.practice.info_none'
    }
  }, [exercise.type, conceptCount, unlockedExercisesCount])

  return (
    <Modal
      cover
      open={open}
      className="m-completed-exercise c-completed-exercise-progress"
      onClose={() => null}
      {...props}
    >
      <ExerciseIcon iconUrl={exercise.iconUrl} />

      <h2>
        {t('exerciseCompletedModal.youCompleted', {
          exerciseTitle: exercise.title,
        })}
      </h2>

      {exercise.type === 'concept' ? (
        <>
          <h3>
            {t('exerciseCompletedModal.awesomeWorkLearning', {
              trackTitle: track.title,
            })}
          </h3>

          {conceptInfoKey ? (
            <div className="info">
              <Trans
                t={t}
                i18nKey={conceptInfoKey}
                values={{
                  count: conceptCount,
                  unlockedExercisesCount,
                }}
                components={{ strong: <strong /> }}
              />
            </div>
          ) : null}

          {conceptCount > 0 && (
            <div className="progressed-concepts">
              {conceptProgressions.map((progression) => (
                <ConceptProgression key={progression.name} {...progression} />
              ))}
            </div>
          )}

          {(unlockedExercises.length !== 0 ||
            unlockedConcepts.length !== 0) && (
            <Unlocks
              unlockedExercises={unlockedExercises}
              unlockedConcepts={unlockedConcepts}
            />
          )}

          <div className="btns">
            {track.numConcepts > 0 && (
              <a href={track.links.concepts} className="btn-primary btn-m">
                {t('exerciseCompletedModal.showMeMoreConcepts')}
              </a>
            )}
            <button onClick={handleContinue} className="btn">
              {t('exerciseCompletedModal.returnToExercise')}
            </button>
          </div>
        </>
      ) : (
        <>
          <h3>
            {t('exerciseCompletedModal.awesomeWorkMastering', {
              trackTitle: track.title,
            })}
          </h3>

          <div className="info">
            <Trans
              t={t}
              i18nKey={
                conceptInfoKey ?? 'exerciseCompletedModal.practice.info_none'
              }
              values={{ count: conceptCount, trackTitle: track.title }}
              components={{ strong: <strong /> }}
            />
          </div>

          {conceptCount > 0 && (
            <div className="progressed-concepts">
              {conceptProgressions.map((progression) => (
                <ConceptProgression key={progression.name} {...progression} />
              ))}
            </div>
          )}

          <div className="btns">
            <a href={track.links.exercises} className="btn-primary btn-m">
              {t('exerciseCompletedModal.showMeMoreExercises')}
            </a>
            <button onClick={handleContinue} className="btn">
              {t('exerciseCompletedModal.returnToExercise')}
            </button>
          </div>
        </>
      )}
    </Modal>
  )
}
