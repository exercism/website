import React, { useCallback, useState, useEffect, useContext } from 'react'
import { Icon } from '../../common/Icon'
import { Keybindings, Themes, EditorSettings } from '../types'
import { useDropdown } from '../../dropdowns/useDropdown'
import { FeaturesContext } from '../../Editor'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const THEMES = [
  { label: 'Light', value: Themes.LIGHT },
  { label: 'Dark', value: Themes.DARK },
]

const KEYBINDINGS = [
  { label: 'Default', value: Keybindings.DEFAULT },
  { label: 'Vim', value: Keybindings.VIM },
  { label: 'Emacs', value: Keybindings.EMACS },
]

const WRAP = [
  { label: 'On', value: 'on' },
  { label: 'Off', value: 'off' },
]

const TAB_MODE = [
  { label: 'Editor', value: 'captured' },
  { label: 'Accessibility', value: 'default' },
]

type SettingProp = {
  title: string
  value: string | Keybindings
  options: { label: string; value: string | Keybindings }[]
  set: (value: string) => void
}

const Setting = React.forwardRef<
  HTMLLIElement,
  React.HTMLProps<HTMLLIElement> & SettingProp
>(({ title, options, value, set, ...props }, ref) => {
  const handleKeyDown = useCallback(
    (e) => {
      const index = options.findIndex((option) => option.value === value)

      switch (e.key) {
        case 'ArrowRight': {
          e.preventDefault()
          const nextIndex = (index + options.length + 1) % options.length

          set(options[nextIndex].value)

          break
        }
        case 'ArrowLeft': {
          e.preventDefault()
          const nextIndex = (index + options.length - 1) % options.length

          set(options[nextIndex].value)

          break
        }
        default: {
          if (!props.onKeyDown) {
            return
          }

          props.onKeyDown(e)

          break
        }
      }
    },
    [options, props, set, value]
  )

  return (
    <li ref={ref} className="setting" {...props} onKeyDown={handleKeyDown}>
      <div className="name">{title}</div>
      <div className="options">
        {options.map((option) => (
          <label key={option.value}>
            <input
              type="radio"
              value={option.value}
              name={title}
              checked={value === option.value}
              onChange={(e) => {
                set(e.target.value)
              }}
            />
            <div className="label">{option.label}</div>
          </label>
        ))}
      </div>
    </li>
  )
})

export function Settings({
  settings,
  setSettings,
}: {
  settings: EditorSettings
  setSettings: (settings: EditorSettings) => void
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/header')
  const features = useContext(FeaturesContext)
  const [localKeybindings, setLocalKeybindings] = useState(settings.keybindings)
  const handleThemeChange = useCallback(
    (theme) => {
      setSettings({ ...settings, theme: theme })
    },
    [setSettings, settings]
  )

  const handleWrapChange = useCallback(
    (wrap) => {
      setSettings({ ...settings, wrap: wrap })
    },
    [setSettings, settings]
  )

  const handleTabBehaviorChange = useCallback(
    (tabBehavior) => {
      setSettings({ ...settings, tabBehavior: tabBehavior })
    },
    [setSettings, settings]
  )

  const dropdownOptions: SettingProp[] = [
    {
      title: t('settings.theme'),
      value: settings.theme,
      options: THEMES.map((theme) => ({
        ...theme,
        label: t(`settings.${theme.label.toLowerCase()}`),
      })),
      set: handleThemeChange,
    },
    {
      title: t('settings.keybindings'),
      value: localKeybindings,
      options: KEYBINDINGS,
      set: (keybinding) => setLocalKeybindings(keybinding as Keybindings),
    },
    {
      title: t('settings.wrap'),
      value: settings.wrap,
      options: WRAP.map((wrap) => ({
        ...wrap,
        label: t(`settings.${wrap.label.toLowerCase()}`),
      })),
      set: handleWrapChange,
    },
    {
      title: t('settings.tabMode'),
      value: settings.tabBehavior,
      options: TAB_MODE.map((tabMode) => ({
        ...tabMode,
        label: t(`settings.${tabMode.label.toLowerCase()}`),
      })),
      set: handleTabBehaviorChange,
    },
  ]

  const optionsToShow = dropdownOptions.filter((option) => {
    switch (option.title) {
      case t('settings.theme'):
        return features.theme
      case t('settings.keybindings'):
        return features.keybindings
      default:
        return true
    }
  })

  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(optionsToShow.length, undefined, {
    placement: 'bottom-end',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [-8, 8],
        },
      },
    ],
  })

  useEffect(() => {
    if (open) {
      return
    }

    if (settings.keybindings === localKeybindings) {
      return
    }

    setSettings({ ...settings, keybindings: localKeybindings })
  }, [localKeybindings, open, setSettings, settings])

  return (
    <React.Fragment>
      <button className="settings-btn" {...buttonAttributes}>
        <Icon icon="settings" alt="Settings" />
      </button>
      {open ? (
        <div
          {...panelAttributes}
          tabIndex={-1}
          role="dialog"
          aria-label="A series of radio buttons to configure the Exercism's code editor"
          className="settings-dialog"
        >
          <ul {...listAttributes}>
            {optionsToShow.map((option, i) => {
              return (
                <Setting
                  key={option.title}
                  {...option}
                  {...itemAttributes(i)}
                />
              )
            })}
          </ul>
        </div>
      ) : null}
    </React.Fragment>
  )
}
