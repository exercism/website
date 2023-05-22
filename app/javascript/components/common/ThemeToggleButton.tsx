import React, { useCallback } from 'react'
import { useThemeObserver } from '@/hooks'
import { useTheme } from '../settings/theme-preference-form'
import { GenericTooltip } from '../misc/ExercismTippy'

export type ThemeToggleButtonProps = {
  disabled: boolean
  links: { update: string; premium: string }
}

export function ThemeToggleButton({
  links,
  disabled,
}: ThemeToggleButtonProps): JSX.Element {
  const { binaryTheme } = useThemeObserver()
  const { handleThemeUpdate } = useTheme(binaryTheme?.split('-')[1], links)

  const switchToDarkTheme = useCallback(
    (e) => {
      handleThemeUpdate({ value: 'dark' }, e)
    },
    [handleThemeUpdate]
  )
  const switchToLightTheme = useCallback(
    (e) => {
      handleThemeUpdate({ value: 'light' }, e)
    },
    [handleThemeUpdate]
  )

  return (
    <GenericTooltip
      content={<DisabledTooltip premiumLink={links.premium} />}
      placement="bottom"
      interactive
      disabled={!disabled}
    >
      <div>
        <button
          onClick={(e) => {
            binaryTheme === 'theme-light'
              ? switchToDarkTheme(e)
              : switchToLightTheme(e)
          }}
          disabled={disabled}
          className="toggle-button"
        >
          <label className="switch">
            <input
              type="checkbox"
              readOnly
              checked={binaryTheme === 'theme-dark'}
            />
            <span className="slider round" />
          </label>
        </button>
      </div>
    </GenericTooltip>
  )
}

function DisabledTooltip({
  premiumLink,
}: {
  premiumLink: string
}): JSX.Element {
  return (
    <div className="flex text-14">
      Become&nbsp;
      <a className="text-14 text-launchingYellow" href={premiumLink}>
        Premium
      </a>
      &nbsp;to use this feature!
    </div>
  )
}
