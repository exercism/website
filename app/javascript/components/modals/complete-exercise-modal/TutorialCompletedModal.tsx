import React from 'react'
import { Modal } from '../Modal'
import { GraphicalIcon } from '../../common'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TutorialCompletedModal = ({
  open,
  completion,
}: {
  open: boolean
  completion: ExerciseCompletion
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/complete-exercise-modal')

  return (
    <Modal
      cover={true}
      open={open}
      className="m-completed-tutorial-exercise"
      onClose={() => {}}
    >
      <GraphicalIcon icon="hello-world" category="graphics" />
      <h2>
        {t('tutorialCompletedModal.journeyStart', {
          trackTitle: completion.exercise.title,
        })}
      </h2>
      <h3>
        {t('tutorialCompletedModal.journeyStart', {
          trackTitle: completion.track.title,
        })}
      </h3>
      <p>
        {t('tutorialCompletedModal.readyToGetStuck')}
        <a href={completion.track.links.exercises}>
          {t('tutorialCompletedModal.realExercises')}
        </a>
        .
        {completion.track.course ? (
          <>
            <br />
            {t('tutorialCompletedModal.weHaveAlsoRevealed', {
              trackTitle: completion.track.title,
            })}
            {completion.track.numConcepts}{' '}
            {t('tutorialCompletedModal.conceptCount', {
              conceptCount: completion.track.numConcepts,
            })}
          </>
        ) : (
          ''
        )}
      </p>
      <div className="info">
        {t('tutorialCompletedModal.accessToMentoring')}
      </div>
      <div className="btns">
        {completion.track.course ? (
          <a
            href={completion.track.links.concepts}
            className="btn-primary btn-m"
          >
            <span>{t('tutorialCompletedModal.showMeConcepts')}</span>
            <GraphicalIcon icon="arrow-right" />
          </a>
        ) : (
          <a
            href={completion.track.links.exercises}
            className="btn-primary btn-m"
          >
            Show me more exercises
          </a>
        )}
        <a href={completion.exercise.links.self} className="btn">
          {t('tutorialCompletedModal.returnToTutorial', {
            exerciseTitle: completion.exercise.title,
          })}
        </a>
      </div>
    </Modal>
  )
}
