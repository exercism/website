import React, { ChangeEvent, useCallback, useState, useEffect } from 'react'
import { Icon } from '../../common/Icon'
import { Keybindings, WrapSetting, Themes } from '../types'
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

const Setting = ({
  title,
  options,
  value,
  onChange,
}: {
  title: string
  value: string | Keybindings
  options: { label: string; value: string | Keybindings }[]
  onChange: (e: ChangeEvent) => void
}) => (
  <React.Fragment>
    <div className="name">{title}</div>
    <div className="options">
      {options.map((option) => (
        <label key={option.value}>
          <input
            type="radio"
            value={option.value}
            name={title}
            checked={value === option.value}
            onChange={onChange}
          />
          <div className="label">{option.label}</div>
        </label>
      ))}
    </div>
  </React.Fragment>
)

export function Settings({
  theme,
  keybindings,
  wrap,
  setTheme,
  setKeybindings,
  setWrap,
}: {
  theme: string
  keybindings: Keybindings
  wrap: WrapSetting
  setTheme: (theme: Themes) => void
  setKeybindings: (keybinding: Keybindings) => void
  setWrap: (wrap: WrapSetting) => void
}) {
  const [localKeybindings, setLocalKeybindings] = useState(keybindings)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
    setOpen,
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

  const handleThemeChange = useCallback(
    (e) => {
      setTheme(e.target.value)
    },
    [setTheme]
  )
  const handleKeybindingsChange = useCallback(
    (e) => {
      setLocalKeybindings(e.target.value as Keybindings)
    },
    [setLocalKeybindings]
  )
  const handleWrapChange = useCallback(
    (e) => {
      setWrap(e.target.value as WrapSetting)
    },
    [setWrap]
  )

  useEffect(() => {
    if (open) {
      return
    }

    setKeybindings(localKeybindings)
  }, [localKeybindings, open, setKeybindings])

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
            <li className="setting" {...itemAttributes(0)}>
              <Setting
                title="Theme"
                value={theme}
                options={THEMES}
                onChange={handleThemeChange}
              />
            </li>
            <li className="setting" {...itemAttributes(1)}>
              <Setting
                title="Keybindings"
                value={localKeybindings}
                options={KEYBINDINGS}
                onChange={handleKeybindingsChange}
              />
            </li>
            <li className="setting" {...itemAttributes(2)}>
              <Setting
                title="Wrap"
                value={wrap}
                options={WRAP}
                onChange={handleWrapChange}
              />
            </li>
          </ul>
        </div>
      ) : null}
    </React.Fragment>
  )
}
