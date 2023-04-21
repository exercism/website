import React, { useState, useCallback } from 'react'
import { FormButton, GraphicalIcon, Icon } from '../common'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { ExercismTippy } from '../misc/ExercismTippy'

export type ThemePreferenceLinks = {
  update: string
  insidersPath: string
}

type RequestBody = {
  user: {
    theme_preference: string
  }
}

type Theme = {
  label: string
  background: string
  iconFilter: string
  value: string
}

function setThemeClassName(theme: string) {
  const body = document.querySelector('body')
  if (!body) return

  const currentTheme = body.classList.value.match(/theme-\S+/)?.[0]
  const newTheme = `theme-${theme}`

  if (newTheme === currentTheme) {
    return
  }

  if (!currentTheme) {
    body.classList.add(newTheme)
  } else {
    body.classList.replace(currentTheme, newTheme)
  }
}

const DEFAULT_ERROR = new Error('Unable to update theme preference')
const THEME_BUTTON_SIZE = 130
const THEMES: Theme[] = [
  {
    label: 'Light',
    value: 'light',
    background: 'white',
    iconFilter: 'textColor1',
  },
  {
    label: 'System',
    value: 'unset',
    background:
      'linear-gradient(135deg, rgba(255,255,255,1) 50%, rgba(48,43,66,1) 50%)',
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
  links: ThemePreferenceLinks
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

  const handleThemeUpdate = useCallback((t) => {
    setTheme(t.value)
    setThemeClassName(t.value)
  }, [])

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2 className="!mb-4">Theme</h2>
      <InfoMessage
        insidersStatus={insidersStatus}
        insidersPath={links.insidersPath}
      />
      <div className="flex gap-32">
        {THEMES.map((t: Theme) => (
          <ThemeButton
            key={t.label}
            theme={t}
            currentTheme={theme}
            disabled={isDisabled(insidersStatus, t.value)}
            onClick={() => handleThemeUpdate(t)}
          />
        ))}
      </div>
      <div className="form-footer">
        <FormButton status={status} type="submit" className="btn-primary btn-m">
          Update theme preference
        </FormButton>
        <FormMessage
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
          SuccessMessage={() => <SuccessMessage />}
        />
      </div>
    </form>
  )
}

const SuccessMessage = () => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your theme has been updated!
    </div>
  )
}

function InfoMessage({
  insidersStatus,
  insidersPath,
}: {
  insidersStatus: string
  insidersPath: string
}): JSX.Element {
  switch (insidersStatus) {
    case 'active':
    case 'active_lifetime':
      return (
        <p className="text-p-base mb-16">
          We hope you enjoy it. Thanks for all your support.
        </p>
      )
    case 'eligible':
    case 'eligible_lifetime':
      return (
        <p className="text-p-base mb-16">
          You&apos;re eligible to join Insiders.{' '}
          <a href={insidersPath}>Get started here.</a>
        </p>
      )
    case 'ineligible':
      return (
        <p className="text-p-base mb-16">
          Dark theme is only available to Exercism Insiders.
        </p>
      )
    default:
      return (
        <p className="text-p-base mb-16">
          [Learn more about Exercism Insiders](...).
        </p>
      )
  }
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
          type="button"
          disabled={disabled}
          value={theme.value}
          id={`${theme.value}-theme`}
          style={{
            height: `${THEME_BUTTON_SIZE}px`,
            width: `${THEME_BUTTON_SIZE}px`,
            background: `${theme.background}`,
            filter: disabled ? 'grayscale(0.9)' : '',
            opacity: disabled ? '60%' : '100%',
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
        <label className="text-p text-15" htmlFor={`${theme.value}-theme`}>
          {theme.label}
        </label>
      </div>
    </ExercismTippy>
  )
}

function DisabledTooltip(): JSX.Element {
  return (
    <div className="flex items-center bg-russianViolet rounded-16 py-8 px-12 text-p-base text-aliceBlue">
      You must be an&nbsp;
      <strong style={{ color: 'inherit' }} className="flex items-center">
        Exercism Insider&nbsp;
        <GraphicalIcon icon="insiders" height={24} width={24} />
      </strong>
      &nbsp;to unlock this theme.
    </div>
  )
}

function isDisabled(insidersStatus: string, theme: string): boolean {
  const active = [
    'active',
    'active_lifetime',
    'eligible',
    'eligible_lifetime',
  ].includes(insidersStatus)
  const disabledTheme = ['dark', 'system'].includes(theme)

  return !active && disabledTheme
}
