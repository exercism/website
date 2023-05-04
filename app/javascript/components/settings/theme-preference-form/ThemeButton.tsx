import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { ExercismTippy } from '@/components/misc/ExercismTippy'
import { DisabledTooltip } from './DisabledTooltip'
import { isButtonDisabled } from './utils'
import type { Theme } from '../ThemePreferenceForm'

const THEME_BUTTON_SIZE = 130
export function ThemeButton({
  theme,
  currentTheme,
  onClick,
  disabledInfo,
}: {
  theme: Theme
  onClick: React.MouseEventHandler<HTMLButtonElement>
  currentTheme: string
  disabledInfo: isButtonDisabled
}): JSX.Element {
  const selected = theme.value === currentTheme

  const nonInsider = disabledInfo.level === 'non-insider'
  const { disabled } = disabledInfo

  return (
    <ExercismTippy content={nonInsider && <DisabledTooltip />}>
      <div className="flex flex-col gap-16 items-center">
        <button
          type="submit"
          disabled={disabled}
          value={theme.value}
          id={`${theme.value}-theme`}
          style={{
            height: `${THEME_BUTTON_SIZE}px`,
            width: `${THEME_BUTTON_SIZE}px`,
            background: `${theme.background}`,
            filter: nonInsider ? 'grayscale(0.9)' : '',
            opacity: nonInsider ? '60%' : '100%',
          }}
          className={`flex items-center justify-center border-1 border-borderColor6 rounded-8 ${
            selected && '--selected-theme'
          }`}
          onClick={onClick}
        >
          <GraphicalIcon
            icon={nonInsider ? 'lock-circle' : theme.icon}
            height={64}
            width={64}
          />
        </button>
        <label
          className="text-p text-15 font-semibold"
          style={{ filter: nonInsider ? 'grayscale(0.9)' : '' }}
          htmlFor={`${theme.value}-theme`}
        >
          {theme.label}
        </label>
      </div>
    </ExercismTippy>
  )
}
