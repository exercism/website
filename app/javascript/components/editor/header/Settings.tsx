import React, { useCallback } from 'react'
import { Icon } from '../../common/Icon'
import { Keybindings, WrapSetting } from '../types'
import { usePanel } from './usePanel'

const THEMES = [
  { label: 'Light', value: 'vs' },
  { label: 'Dark', value: 'vs-dark' },
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
  setTheme: (theme: string) => void
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
            <div className="setting">
              <div className="name">Theme</div>
              {THEMES.map((setting) => (
                <label key={setting.value}>
                  {setting.label}
                  <input
                    type="radio"
                    value={setting.value}
                    checked={theme === setting.value}
                    onChange={handleThemeChange}
                  />
                </label>
              ))}
            </div>
            <div className="setting">
              <div className="name">Keybindings</div>
              {KEYBINDINGS.map((setting) => (
                <label key={setting.value}>
                  {setting.label}
                  <input
                    type="radio"
                    value={setting.value as string}
                    checked={keybindings === setting.value}
                    onChange={handleKeybindingsChange}
                  />
                </label>
              ))}
            </div>
            <div className="setting">
              <div className="name">Wrap</div>
              {WRAP.map((setting) => (
                <label key={setting.value}>
                  {setting.label}
                  <input
                    type="radio"
                    value={setting.value}
                    checked={wrap === setting.value}
                    onChange={handleWrapChange}
                  />
                </label>
              ))}
            </div>
          </div>
        ) : null}
      </div>
    </div>
  )
}
