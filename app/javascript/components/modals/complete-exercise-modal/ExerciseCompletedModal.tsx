import React, { useCallback } from 'react'
import { Modal } from '../Modal'
import { ExerciseIcon } from '../../common'
import { ConceptProgression } from './exercise-completed-modal/ConceptProgression'
import { Unlocks } from './exercise-completed-modal/Unlocks'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { redirectTo } from '../../../utils/redirect-to'
import pluralize from 'pluralize'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ExerciseCompletedModal = ({
  open,
  completion,
  ...props
}: {
  open: boolean
  completion: ExerciseCompletion
}): JSX.Element => {
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

  const content =
    exercise.type == 'concept' ? (
      <>
        <h3>
          {t('exerciseCompletedModal.awesomeWorkLearning', {
            trackTitle: track.title,
          })}
        </h3>
        {conceptProgressions.length > 0 ? (
          <div className="info">
            {t('exerciseCompletedModal.learntConcepts')}
            <strong>
              {conceptProgressions.length}{' '}
              {t('exerciseCompletedModal.conceptsCount', {
                count: conceptProgressions.length,
              })}
            </strong>
            {unlockedExercises.length > 0
              ? t('exerciseCompletedModal.unlockedExercises', {
                  unlockedExercisesCount: unlockedExercises.length,
                }) + t('exerciseCompletedModal.byCompleting')
              : null}{' '}
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
              {t('exerciseCompletedModal.showMeMoreConcepts')}
            </a>
          ) : null}
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
        {conceptProgressions.length > 0 ? (
          <>
            <div className="info">
              {t('exerciseCompletedModal.progressedWith')}
              <strong>
                {conceptProgressions.length}{' '}
                {t('exerciseCompletedModal.conceptsCount', {
                  count: conceptProgressions.length,
                })}
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
            {t('exerciseCompletedModal.oncePracticedMore', {
              trackTitle: track.title,
            })}
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
      <h2>
        {t('exerciseCompletedModal.youCompleted', {
          exerciseTitle: exercise.title,
        })}
      </h2>
      {content}
    </Modal>
  )
}
