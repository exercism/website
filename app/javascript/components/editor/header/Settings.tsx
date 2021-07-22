import React, { useCallback, useState, useEffect } from 'react'
import { Icon } from '../../common/Icon'
import { Keybindings, Themes, EditorSettings } from '../types'
import { useDropdown } from '../../dropdowns/useDropdown'

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

const Setting = React.forwardRef<
  HTMLLIElement,
  React.HTMLProps<HTMLLIElement> & {
    title: string
    value: string | Keybindings
    options: { label: string; value: string | Keybindings }[]
    set: (value: string) => void
  }
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
}) {
  const [localKeybindings, setLocalKeybindings] = useState(settings.keybindings)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(3, undefined, {
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
            <Setting
              title="Theme"
              value={settings.theme}
              options={THEMES}
              set={handleThemeChange}
              {...itemAttributes(0)}
            />
            {/*<Setting
              title="Keybindings"
              value={localKeybindings}
              options={KEYBINDINGS}
              set={(keybinding) =>
                setLocalKeybindings(keybinding as Keybindings)
              }
              {...itemAttributes(1)}
            />*/}
            <Setting
              title="Wrap"
              value={settings.wrap}
              options={WRAP}
              set={handleWrapChange}
              {...itemAttributes(2)}
            />
            <Setting
              title="Tab mode"
              value={settings.tabBehavior}
              options={TAB_MODE}
              set={handleTabBehaviorChange}
              {...itemAttributes(3)}
            />
          </ul>
        </div>
      ) : null}
    </React.Fragment>
  )
}
