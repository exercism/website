import React from 'react'
import pluralize from 'pluralize'
import { GraphicalIcon, Icon } from '../../common'
import { toSentence } from '../../../utils/toSentence'
import { ExerciseType, Iteration, IterationStatus } from '../../types'

export type SolutionSummaryLinks = {
  testsPassLocallyArticle: string
}

export type Exercise = {
  title: string
  type: ExerciseType
}
const TutorialHeader = ({ exercise }: { exercise: Exercise }) => {
  return (
    <header>
      <div className="info">
        <h2>Your solution looks good!</h2>
        <p>
          <strong>Good job.</strong> Your solution to &quot;{exercise.title}
          !&quot; has passed all the tests 😊
        </p>
      </div>
      <div className="status passed">Tests Passed</div>
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
  switch (iteration.status) {
    case IterationStatus.DELETED:
    case IterationStatus.UNTESTED:
      return <></>
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return (
        <header>
          <div className="info">
            <h2>Your solution is being processed…</h2>
            <p>
              Your solution is currently being tested, analysed, and compared to
              other solutions to find potential improvements. This should only
              take a few seconds.
            </p>
          </div>
          <GraphicalIcon icon="spinner" className="spinner" />
        </header>
      )
    case IterationStatus.TESTS_FAILED:
      return (
        <header>
          <div className="info">
            <h2>Your solution failed the tests.</h2>
            <p>
              Hmmm, it looks like your solution isn&apos;t working. Please check
              that the tests pass locally on your machine. If they do pass for
              you, please read{' '}
              <a
                href={links.testsPassLocallyArticle}
                rel="noreferrer"
                target="_blank"
              >
                this article{' '}
                <Icon icon="external-link" alt="Opens in a new tab" />
              </a>
            </p>
          </div>
          <div className="status failed">Tests Failed</div>
        </header>
      )
    case IterationStatus.ESSENTIAL_AUTOMATED_FEEDBACK: {
      if (exercise.type === 'tutorial') {
        return <TutorialHeader exercise={exercise} />
      }

      const comments = [
        `${iteration.numEssentialAutomatedComments} essential ${pluralize(
          'improvement',
          iteration.numEssentialAutomatedComments
        )}`,
        iteration.numActionableAutomatedComments > 0
          ? `${iteration.numActionableAutomatedComments} ${pluralize(
              'recommendation',
              iteration.numActionableAutomatedComments
            )}`
          : '',
        iteration.numNonActionableAutomatedComments > 0
          ? `${
              iteration.numNonActionableAutomatedComments +
              iteration.numCelebratoryAutomatedComments
            } additional ${pluralize(
              'comment',
              iteration.numNonActionableAutomatedComments +
                iteration.numCelebratoryAutomatedComments
            )}`
          : '',
      ].filter((comment) => comment.length > 0)

      return (
        <header>
          <div className="info">
            <h2>Your solution worked, but you can take it further…</h2>
            <p>
              We’ve analysed your solution and have {toSentence(comments)}.
              Address the essential improvements before proceeding.
            </p>
          </div>
          <div className="status passed">Tests Passed</div>
        </header>
      )
    }
    case IterationStatus.NO_AUTOMATED_FEEDBACK:
      if (exercise.type === 'tutorial') {
        return <TutorialHeader exercise={exercise} />
      }

      return (
        <header>
          <div className="info">
            <h2>Your solution looks great!</h2>
            <p>
              Your solution passed the tests and we don&apos;t have any
              recommendations.{' '}
              {exercise.type === 'practice'
                ? 'You might want to work with a mentor to make it even better.'
                : null}{' '}
              <strong>Great Job! 🎉</strong>
            </p>
          </div>
          <div className="status passed">Tests Passed</div>
        </header>
      )
    case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
    case IterationStatus.CELEBRATORY_AUTOMATED_FEEDBACK:
      if (exercise.type === 'tutorial') {
        return <TutorialHeader exercise={exercise} />
      }

      return (
        <header>
          <div className="info">
            <h2>Your solution looks great!</h2>
            <p>
              We’ve analysed your solution and not found anything that needs
              changing. We do have{' '}
              <span className="non-actionable">
                {iteration.numNonActionableAutomatedComments +
                  iteration.numCelebratoryAutomatedComments}{' '}
                additional{' '}
                {pluralize(
                  'comment',
                  iteration.numNonActionableAutomatedComments +
                    iteration.numCelebratoryAutomatedComments
                )}
              </span>{' '}
              that you might like to check.{' '}
              {exercise.type === 'practice'
                ? 'Consider working with a mentor to make it even better. '
                : ' '}
              <strong>Great Job! 🎉</strong>
            </p>
          </div>
          <div className="status passed">Tests Passed</div>
        </header>
      )
    case IterationStatus.ACTIONABLE_AUTOMATED_FEEDBACK: {
      if (exercise.type === 'tutorial') {
        return <TutorialHeader exercise={exercise} />
      }

      const comments = [
        `${iteration.numActionableAutomatedComments} ${pluralize(
          'recommendation',
          iteration.numActionableAutomatedComments
        )}`,
        iteration.numNonActionableAutomatedComments > 0
          ? `${
              iteration.numNonActionableAutomatedComments +
              iteration.numCelebratoryAutomatedComments
            } additional ${pluralize(
              'comment',
              iteration.numNonActionableAutomatedComments +
                iteration.numCelebratoryAutomatedComments
            )}`
          : '',
      ].filter((comment) => comment.length > 0)

      switch (exercise.type) {
        case 'concept':
          return (
            <header>
              <div className="info">
                <h2>Your solution is good enough to continue!</h2>
                <p>
                  We’ve analysed your solution and have {toSentence(comments)}.
                  You can either continue or address the{' '}
                  {pluralize(
                    'recommendation',
                    iteration.numActionableAutomatedComments
                  )}{' '}
                  first - your choice!
                </p>
              </div>
              <div className="status passed">Tests Passed</div>
            </header>
          )
        case 'practice':
          return (
            <header>
              <div className="info">
                <h2>Your solution worked, but you can take it further…</h2>
                <p>
                  We’ve analysed your solution and have {toSentence(comments)}.
                  We suggest addressing the{' '}
                  {pluralize(
                    'recommendation',
                    iteration.numActionableAutomatedComments
                  )}{' '}
                  before proceeding.
                </p>
              </div>
              <div className="status passed">Tests Passed</div>
            </header>
          )
      }
    }
  }
}
