import React from 'react'
import { Modal } from '../Modal'
import { GraphicalIcon } from '../../common'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const TutorialCompletedModal = ({
  open,
  completion,
}: {
  open: boolean
  completion: ExerciseCompletion
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/complete-exercise-modal')

  const hasCourse = Boolean(completion.track.course)

  return (
    <Modal
      cover
      open={open}
      className="m-completed-tutorial-exercise"
      onClose={() => {}}
    >
      <GraphicalIcon icon="hello-world" category="graphics" />

      <h2>
        {t('tutorialCompletedModal.heading', {
          exerciseTitle: completion.exercise.title,
        })}
      </h2>

      <h3>
        {t('tutorialCompletedModal.subheading', {
          trackTitle: completion.track.title,
        })}
      </h3>

      <p>
        <Trans
          ns="components/modals/complete-exercise-modal"
          i18nKey={
            hasCourse
              ? 'tutorialCompletedModal.body.withCourse'
              : 'tutorialCompletedModal.body.noCourse'
          }
          values={{
            trackTitle: completion.track.title,
            conceptCount: completion.track.numConcepts,
          }}
          components={[<a href={completion.track.links.exercises} />]}
        />
      </p>

      <div className="info">
        {t('tutorialCompletedModal.accessToMentoring')}
      </div>

      <div className="btns">
        {hasCourse ? (
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
            {t('tutorialCompletedModal.showMoreExercises')}
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
