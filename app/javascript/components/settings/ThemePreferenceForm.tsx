import React, { useState, useCallback } from 'react'
import { FormButton, GraphicalIcon, Icon } from '../common'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { ExercismTippy } from '../misc/ExercismTippy'

type Links = {
  update: string
}

type RequestBody = {
  user: {
    theme_preference: string
  }
}

const DEFAULT_ERROR = new Error('Unable to update pronouns')

const THEME_BUTTON_SIZE = 128

type Theme = {
  label: string
  background: string
  iconFilter: string
  value: string
}

const THEMES: Theme[] = [
  {
    label: 'Light',
    value: 'light',
    background: 'white',
    iconFilter: 'textColor1',
  },
  {
    label: 'System',
    value: 'system',
    background:
      'linear-gradient(90deg, rgba(255,255,255,1) 50%, rgba(48,43,66,1) 50%)',
    iconFilter: 'gray',
  },
  {
    label: 'Dark',
    value: 'dark',
    background: '#302b42', //russianViolet
    iconFilter: 'aliceBlue',
  },
  {
    label: 'Accessibility Dark',
    value: 'accessibility-dark',
    background: 'black',
    iconFilter: 'white-no-dark',
  },
]

export const ThemePreferenceForm = ({
  defaultThemePreference,
  insidersStatus,
  links,
}: {
  defaultThemePreference: string
  insidersStatus: string
  links: Links
}): JSX.Element => {
  const [theme, setTheme] = useState<string>(defaultThemePreference || '')

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user: { theme_preference: theme } },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2>Theme</h2>
      <div className="flex gap-32">
        {THEMES.map((t: Theme) => (
          <ThemeButton
            key={t.label}
            theme={t}
            currentTheme={theme}
            disabled={isDisabled(insidersStatus, t.value)}
            onClick={() => setTheme(t.value)}
          />
        ))}
      </div>
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Update theme preference
        </FormButton>
        <FormMessage
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
          SuccessMessage={() => <SuccessMessage theme={theme} />}
        />
      </div>
    </form>
  )
}

const SuccessMessage = ({ theme }: { theme: string }) => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your theme has been set to {theme}
    </div>
  )
}

function ThemeButton({
  theme,
  currentTheme,
  onClick,
  disabled = false,
}: {
  theme: Theme
  onClick: React.MouseEventHandler<HTMLButtonElement>
  currentTheme: string
  disabled?: boolean
}) {
  const selected = theme.value === currentTheme

  return (
    <ExercismTippy content={disabled && <DisabledTooltip />}>
      <div className="flex flex-col gap-16 items-center">
        <button
          disabled={disabled}
          id={`${theme.value}-theme`}
          style={{
            height: `${THEME_BUTTON_SIZE}px`,
            width: `${THEME_BUTTON_SIZE}px`,
            background: `${theme.background}`,
            filter: disabled ? 'grayscale(0.9)' : '',
          }}
          className={`flex items-center justify-center border-1 border-borderColor6 rounded-8 ${
            selected && '--selected-theme'
          }`}
          onClick={onClick}
        >
          <GraphicalIcon
            icon={disabled ? 'lock-circle' : 'logo'}
            height={32}
            width={32}
            className={!disabled ? `filter-${theme.iconFilter}` : ''}
          />
        </button>
        <label className="text-p" htmlFor={`${theme.value}-theme`}>
          {theme.label}
        </label>
      </div>
    </ExercismTippy>
  )
}

function DisabledTooltip(): JSX.Element {
  return (
    <div className="flex items-center bg-russianViolet rounded-16 py-8 px-12 text-p-base text-aliceBlue">
      You must be&nbsp;
      <strong style={{ color: 'inherit' }} className="flex items-center">
        Exercism Insider&nbsp;
        <GraphicalIcon icon="insiders" height={24} width={24} />
      </strong>
      &nbsp;to unlock this theme.
    </div>
  )
}

function isDisabled(insidersStatus: string, theme: string): boolean {
  const eligible = ['eligible', 'eligible_lifetime'].includes(insidersStatus)
  const themeDisabled = ['dark', 'system'].includes(theme)

  return !eligible && themeDisabled
}
