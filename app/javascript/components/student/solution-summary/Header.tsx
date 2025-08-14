import React from 'react'
import { GraphicalIcon, Icon } from '../../common'
import { toSentence } from '../../../utils/toSentence'
import { ExerciseType, Iteration, IterationStatus } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export type SolutionSummaryLinks = {
  testsPassLocallyArticle: string
}

export type Exercise = {
  title: string
  type: ExerciseType
}
const TutorialHeader = ({ exercise }: { exercise: Exercise }) => {
  const { t } = useAppTranslation('components/student/solution-summary')

  return (
    <header>
      <div className="info">
        <h2>{t('header.yourSolutionLooksGood')}</h2>
        <p>
          <Trans
            ns="components/student/solution-summary"
            i18nKey="header.goodJobYourSolutionHasPassedAllTests"
            values={{ exerciseTitle: exercise.title }}
            components={{ strong: <strong /> }}
          />
        </p>
      </div>
      <div className="status passed">{t('status.testsPassed')}</div>
    </header>
  )
}

export const Header = ({
  iteration,
  exercise,
  links,
}: {
  iteration: Iteration
  exercise: Exercise
  links: SolutionSummaryLinks
}): JSX.Element => {
  const { t } = useAppTranslation('components/student/solution-summary')

  switch (iteration.status) {
    case IterationStatus.DELETED:
    case IterationStatus.UNTESTED:
      return <></>

    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return (
        <header>
          <div className="info">
            <h2>{t('header.yourSolutionIsBeingProcessed')}</h2>
            <p>{t('header.yourSolutionIsCurrentlyBeingTested')}</p>
          </div>
          <GraphicalIcon icon="spinner" className="spinner" />
        </header>
      )

    case IterationStatus.TESTS_FAILED:
      return (
        <header>
          <div className="info">
            <h2>{t('header.yourSolutionFailedTheTests')}</h2>
            <p>
              <Trans
                ns="components/student/solution-summary"
                i18nKey="header.hmmmItLooksLikeYourSolutionIsntWorking"
                components={{
                  articleLink: (
                    <a
                      href={links.testsPassLocallyArticle}
                      rel="noreferrer"
                      target="_blank"
                    />
                  ),
                  icon: <Icon icon="external-link" alt="Opens in a new tab" />,
                }}
              />
            </p>
          </div>
          <div className="status failed">{t('status.testsFailed')}</div>
        </header>
      )

    case IterationStatus.ESSENTIAL_AUTOMATED_FEEDBACK: {
      if (exercise.type === 'tutorial') {
        return <TutorialHeader exercise={exercise} />
      }

      const essential = t('comments.essentialImprovements', {
        count: iteration.numEssentialAutomatedComments,
      })
      const actionable =
        iteration.numActionableAutomatedComments > 0
          ? t('comments.recommendations', {
              count: iteration.numActionableAutomatedComments,
            })
          : ''
      const additionalCount =
        iteration.numNonActionableAutomatedComments +
        iteration.numCelebratoryAutomatedComments
      const additional =
        additionalCount > 0
          ? t('comments.additionalComments', { count: additionalCount })
          : ''

      const comments = [essential, actionable, additional].filter(
        Boolean
      ) as string[]

      return (
        <header>
          <div className="info">
            <h2>{t('header.yourSolutionWorkedButYouCanTakeItFurther')}</h2>
            <p>
              {t('header.weveAnalysedYourSolutionAndHave', {
                comments: toSentence(comments),
              })}
            </p>
          </div>
          <div className="status passed">{t('status.testsPassed')}</div>
        </header>
      )
    }

    case IterationStatus.NO_AUTOMATED_FEEDBACK: {
      if (exercise.type === 'tutorial')
        return <TutorialHeader exercise={exercise} />

      const mentorOffer =
        exercise.type === 'practice'
          ? t('header.youMightWantToWorkWithAMentor')
          : ''

      return (
        <header>
          <div className="info">
            <h2>{t('header.yourSolutionLooksGreat')}</h2>
            <p>
              {t('header.yourSolutionPassedTheTestsAndWeDontHave', {
                mentorOffer,
              })}
            </p>
          </div>
          <div className="status passed">{t('status.testsPassed')}</div>
        </header>
      )
    }

    case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
    case IterationStatus.CELEBRATORY_AUTOMATED_FEEDBACK: {
      if (exercise.type === 'tutorial')
        return <TutorialHeader exercise={exercise} />

      const count =
        iteration.numNonActionableAutomatedComments +
        iteration.numCelebratoryAutomatedComments
      const mentorOffer =
        exercise.type === 'practice'
          ? t('header.considerWorkingWithAMentor')
          : ''

      return (
        <header>
          <div className="info">
            <h2>{t('header.yourSolutionLooksGreat')}</h2>
            <p>
              <Trans
                ns="components/student/solution-summary"
                i18nKey="header.weveAnalysedYourSolutionAndNotFoundAnythingThatNeedsChanging"
                values={{ count, mentorOffer }}
                components={{ comments: <span className="non-actionable" /> }}
              />
            </p>
          </div>
          <div className="status passed">{t('status.testsPassed')}</div>
        </header>
      )
    }

    case IterationStatus.ACTIONABLE_AUTOMATED_FEEDBACK: {
      if (exercise.type === 'tutorial')
        return <TutorialHeader exercise={exercise} />

      const actionable = t('comments.recommendations', {
        count: iteration.numActionableAutomatedComments,
      })
      const additionalCount =
        iteration.numNonActionableAutomatedComments +
        iteration.numCelebratoryAutomatedComments
      const additional =
        additionalCount > 0
          ? t('comments.additionalComments', { count: additionalCount })
          : ''
      const comments = [actionable, additional].filter(Boolean) as string[]

      switch (exercise.type) {
        case 'concept':
          return (
            <header>
              <div className="info">
                <h2>{t('header.yourSolutionIsGoodEnoughToContinue')}</h2>
                <p>
                  {t('header.weveAnalysedYourSolutionAndHaveComments', {
                    comments: toSentence(comments),
                    count: iteration.numActionableAutomatedComments,
                  })}
                </p>
              </div>
              <div className="status passed">{t('status.testsPassed')}</div>
            </header>
          )

        case 'practice':
          return (
            <header>
              <div className="info">
                <h2>{t('header.yourSolutionWorkedButYouCanTakeItFurther')}</h2>
                <p>
                  {t('header.weSuggestAddressingTheRecommendations', {
                    count: iteration.numActionableAutomatedComments,
                  })}
                </p>
              </div>
              <div className="status passed">{t('status.testsPassed')}</div>
            </header>
          )
      }
    }
  }
}
