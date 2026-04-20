import React, { useContext } from 'react'
import { Iteration } from '../../types'
import { IterationButton } from './IterationButton'
import { Icon } from '../../common/Icon'
import { ScreenSizeContext } from './ScreenSizeContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const NavigationButtons = ({
  iterations,
  current,
  onClick,
}: {
  iterations: readonly Iteration[]
  current: Iteration
  onClick: (iteration: Iteration) => void
}) => {
  const { t } = useAppTranslation('session-batch-2')
  const currentIndex = iterations.findIndex((i) => i.idx === current.idx)

  return (
    <React.Fragment>
      <button
        type="button"
        aria-label={t(
          'components.mentoring.session.iterationsList.goToPreviousIteration'
        )}
        onClick={() => onClick(iterations[currentIndex - 1])}
        disabled={iterations[0].idx === current.idx}
        className="btn-keyboard-shortcut previous"
      >
        <div className="--kb">
          <Icon icon="arrow-left" alt="Left arrow" />
        </div>
        <div className="--hint">
          {t('components.mentoring.session.iterationsList.previous')}
        </div>
      </button>
      <button
        type="button"
        aria-label={t(
          'components.mentoring.session.iterationsList.goToNextIteration'
        )}
        onClick={() => onClick(iterations[currentIndex + 1])}
        disabled={iterations[iterations.length - 1].idx === current.idx}
        className="btn-keyboard-shortcut next"
      >
        <div className="--hint">
          {t('components.mentoring.session.iterationsList.next')}
        </div>
        <div className="--kb">
          <Icon icon="arrow-right" alt="Right arrow" />
        </div>
      </button>
    </React.Fragment>
  )
}

export const IterationsList = ({
  iterations,
  current,
  onClick,
}: {
  iterations: readonly Iteration[]
  current: Iteration
  onClick: (iteration: Iteration) => void
}): JSX.Element => {
  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}

  return (
    <>
      <nav className="iterations scroll-x-hidden">
        {iterations.map((iteration) => (
          <IterationButton
            key={iteration.idx}
            iteration={iteration}
            onClick={() => onClick(iteration)}
            selected={current.idx === iteration.idx}
          />
        ))}
      </nav>

      {/* TODO: (optional) Move this into a component that can take either an icon or a character as the contents of --kb */}
      {iterations.length > 1 && !isBelowLgWidth ? (
        <NavigationButtons
          iterations={iterations}
          current={current}
          onClick={onClick}
        />
      ) : null}
    </>
  )
}
