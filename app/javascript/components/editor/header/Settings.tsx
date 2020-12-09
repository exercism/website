import React, { useState, useRef, useEffect } from 'react'
import { usePopper } from 'react-popper'
import { Icon } from '../../common/Icon'
import { Keybindings, WrapSetting } from '../types'

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
  const [open, setOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const panelRef = useRef<HTMLDivElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)
  const { styles, attributes, update: updatePanelPosition } = usePopper(
    buttonRef.current,
    panelRef.current,
    {
      placement: 'bottom',
    }
  )

  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      const clickedOutsideComponent = !componentRef.current?.contains(
        e.target as Node
      )

      if (clickedOutsideComponent) {
        setOpen(false)
      }
    }

    document.addEventListener('click', handleClick)

    return () => {
      document.removeEventListener('click', handleClick)
    }
  }, [])

  useEffect(() => {
    if (!open || !updatePanelPosition) {
      return
    }

    updatePanelPosition()
  }, [open])

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
              <div className="name">Keybindings</div>
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
              <div className="name">Wrap</div>
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
