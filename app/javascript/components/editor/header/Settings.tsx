import React, { ChangeEvent, useCallback, useState, useEffect } from 'react'
import { Icon } from '../../common/Icon'
import { Keybindings, WrapSetting, Themes } from '../types'
import { usePanel } from '../../../hooks/use-panel'

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
  <div className="setting">
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
  </div>
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
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel()

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
      <button
        className="settings-btn"
        type="button"
        aria-haspopup="true"
        aria-expanded={open}
        onClick={() => setOpen(!open)}
        {...buttonAttributes}
      >
        <Icon icon="settings" alt="Settings" />
      </button>
      {open ? (
        <div {...panelAttributes}>
          <div
            tabIndex={-1}
            role="dialog"
            aria-label="A series of radio buttons to configure the Exercism's code editor"
            className="settings-dialog"
          >
            <Setting
              title="Theme"
              value={theme}
              options={THEMES}
              onChange={handleThemeChange}
            />
            <Setting
              title="Keybindings"
              value={localKeybindings}
              options={KEYBINDINGS}
              onChange={handleKeybindingsChange}
            />
            <Setting
              title="Wrap"
              value={wrap}
              options={WRAP}
              onChange={handleWrapChange}
            />
          </div>
        </div>
      ) : null}
    </React.Fragment>
  )
}
