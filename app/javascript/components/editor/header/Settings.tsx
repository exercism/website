import React, { ChangeEvent, useCallback } from 'react'
import { Icon } from '../../common/Icon'
import { Keybindings, WrapSetting, Themes } from '../types'
import { usePanel } from './usePanel'

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
  const {
    open,
    setOpen,
    buttonRef,
    panelRef,
    componentRef,
    styles,
    attributes,
  } = usePanel()

  const handleThemeChange = useCallback(
    (e) => {
      setTheme(e.target.value)
    },
    [setTheme]
  )
  const handleKeybindingsChange = useCallback(
    (e) => {
      setKeybindings(e.target.value as Keybindings)
    },
    [setKeybindings]
  )
  const handleWrapChange = useCallback(
    (e) => {
      setWrap(e.target.value as WrapSetting)
    },
    [setWrap]
  )

  return (
    <div ref={componentRef}>
      <button
        ref={buttonRef}
        className="settings-btn"
        type="button"
        onClick={() => {
          setOpen(!open)
        }}
      >
        <Icon icon="settings" alt="Settings" />
      </button>
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <div className="settings-dialog">
            <Setting
              title="Theme"
              value={theme}
              options={THEMES}
              onChange={handleThemeChange}
            />
            <Setting
              title="Keybindings"
              value={keybindings}
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
        ) : null}
      </div>
    </div>
  )
}
