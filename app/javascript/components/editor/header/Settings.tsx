import React from 'react'
import { Icon } from '../../common/Icon'
import { Keybindings, WrapSetting } from '../types'
import { usePanel } from './usePanel'

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
              <label htmlFor="theme" className="name">
                Theme
              </label>{' '}
              <select
                id="theme"
                onChange={(e) => setTheme(e.target.value)}
                value={theme}
              >
                <option value="vs">Light</option>
                <option value="vs-dark">Dark</option>
              </select>
            </div>
            <div className="setting">
              <label htmlFor="keybindings" className="name">
                Keybindings
              </label>
              <select
                id="keybindings"
                onChange={(e) => setKeybindings(e.target.value as Keybindings)}
                value={keybindings}
              >
                <option value={Keybindings.DEFAULT}>Default</option>
                <option value={Keybindings.VIM}>Vim</option>
                <option value={Keybindings.EMACS}>Emacs</option>
              </select>
            </div>
            <div className="setting">
              <label htmlFor="wrap" className="name">
                Wrap
              </label>
              <select
                id="wrap"
                onChange={(e) => setWrap(e.target.value as WrapSetting)}
                value={wrap}
              >
                <option value="on">On</option>
                <option value="off">Off</option>
              </select>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  )
}
