import React from 'react'
import { GraphicalIcon, Icon } from '../../common'
import { Iteration, IterationStatus } from '../../types'
import pluralize from 'pluralize'

export type SolutionSummaryLinks = {
  testsPassLocallyArticle: string
}

export const Header = ({
  iteration,
  isPracticeExercise,
  links,
}: {
  iteration: Iteration
  isPracticeExercise: boolean
  links: SolutionSummaryLinks
}): JSX.Element => {
  switch (iteration.status) {
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return (
        <header>
          <div className="info">
            <h2>Your solution is being processed...</h2>
            <p>
              Your solution is currently being tested, analysed, and compared to
              other solutions to find for potential improvements. This should
              only take a few seconds.
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
              iteration.numNonActionableAutomatedComments
            } additional ${pluralize(
              'comment',
              iteration.numNonActionableAutomatedComments
            )}`
          : '',
      ].filter((comment) => comment.length > 0)

      return (
        <header>
          <div className="info">
            <h2>Your solution worked, but you can take it further...</h2>
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
      return (
        <header>
          <div className="info">
            <h2>Your solution looks great!</h2>
            <p>
              Your solution passed the tests and we&apos;ve not got any
              recommendations.
              {isPracticeExercise
                ? 'You might want to work with a mentor to make it even better.'
                : null}{' '}
              <strong>Great Job! 🎉</strong>
            </p>
          </div>
          <div className="status passed">Tests Passed</div>
        </header>
      )
    case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
      return (
        <header>
          <div className="info">
            <h2>Your solution looks great!</h2>
            <p>
              We’ve analysed your solution and not found anything that needs
              changing. We do have{' '}
              <span className="non-actionable">
                {iteration.numNonActionableAutomatedComments} additional{' '}
                {pluralize(
                  'comment',
                  iteration.numNonActionableAutomatedComments
                )}
              </span>{' '}
              that you might like to check.{' '}
              {isPracticeExercise
                ? 'Consider working with a mentor to make it even better. '
                : ' '}
              <strong>Great Job! 🎉</strong>
            </p>
          </div>
          <div className="status passed">Tests Passed</div>
        </header>
      )
    case IterationStatus.ACTIONABLE_AUTOMATED_FEEDBACK: {
      const comments = [
        `${iteration.numActionableAutomatedComments} ${pluralize(
          'recommendation',
          iteration.numActionableAutomatedComments
        )}`,
        iteration.numNonActionableAutomatedComments > 0
          ? `${
              iteration.numNonActionableAutomatedComments
            } additional ${pluralize(
              'comment',
              iteration.numNonActionableAutomatedComments
            )}`
          : '',
      ].filter((comment) => comment.length > 0)

      if (isPracticeExercise) {
        return (
          <header>
            <div className="info">
              <h2>Your solution worked, but you can take it further...</h2>
              <p>
                We’ve analysed your solution and have {toSentence(comments)}. We
                suggest addressing the recommendations before proceeding.
              </p>
            </div>
            <div className="status passed">Tests Passed</div>
          </header>
        )
      } else {
        return (
          <header>
            <div className="info">
              <h2>Your solution is good enough to continue!</h2>
              <p>
                We’ve analysed your solution and have {toSentence(comments)}.
                You can either continue or address the recommendations first -
                your choice!
              </p>
            </div>
            <div className="status passed">Tests Passed</div>
          </header>
        )
      }
    }
  }
}

function toSentence(arr: string[]) {
  if (arr.length === 0) {
    return arr[0]
  }

  const last = arr.pop()

  return `${arr.join(', ')} and ${last}`
}
