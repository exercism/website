import React, { useState, useRef, useEffect } from 'react'
import { usePopper } from 'react-popper'
import { Icon } from '../../common/Icon'
import { Keybindings } from './types'

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
  wrap: 'off' | 'on' | 'wordWrapColumn' | 'bounded'
  setTheme: (theme: string) => void
  setKeybindings: (keybinding: Keybindings) => void
  setWrap: (wrap: 'off' | 'on' | 'wordWrapColumn' | 'bounded') => void
}) {
  const [open, setOpen] = useState(false)
  const buttonRef = useRef<HTMLButtonElement>(null)
  const panelRef = useRef<HTMLDivElement>(null)
  const componentRef = useRef<HTMLDivElement>(null)
  const { styles, attributes } = usePopper(
    buttonRef.current,
    panelRef.current,
    {
      placement: 'bottom',
    }
  )

  const handleClickOutside = (e: MouseEvent) => {
    if (componentRef.current?.contains(e.target as Node)) {
      return
    }

    setOpen(false)
  }

  useEffect(() => {
    document.addEventListener('click', handleClickOutside)

    return () => {
      document.removeEventListener('click', handleClickOutside)
    }
  }, [])

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
          <div>
            <label htmlFor="theme">Theme</label>
            <select
              id="theme"
              onChange={(e) => setTheme(e.target.value)}
              value={theme}
            >
              <option value="vs">Light</option>
              <option value="vs-dark">Dark</option>
            </select>
            <label htmlFor="keybindings">Keybindings</label>
            <select
              id="keybindings"
              onChange={(e) => setKeybindings(e.target.value as Keybindings)}
              value={keybindings}
            >
              <option value={Keybindings.DEFAULT}>Default</option>
              <option value={Keybindings.VIM}>Vim</option>
              <option value={Keybindings.EMACS}>Emacs</option>
            </select>
            <label htmlFor="wrap">Wrap</label>
            <select
              id="wrap"
              onChange={(e) =>
                setWrap(
                  e.target.value as 'off' | 'on' | 'wordWrapColumn' | 'bounded'
                )
              }
              value={wrap}
            >
              <option value="on">On</option>
              <option value="off">Off</option>
            </select>
          </div>
        ) : null}
      </div>
    </div>
  )
}
