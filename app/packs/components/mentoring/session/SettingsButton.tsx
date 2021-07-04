import React, { useState, useRef } from 'react'
import { Icon } from '../../common/Icon'
import Tippy from '@tippyjs/react'
import { Settings } from '../Session'

export const SettingsButton = ({
  value,
  setValue,
}: {
  value: Settings
  setValue: (settings: Settings) => void
}): JSX.Element => {
  const [open, setOpen] = useState(false)
  const panelRef = useRef<HTMLDivElement>(null)

  return (
    <Tippy
      content={
        <div ref={panelRef}>
          <label>
            <input
              type="checkbox"
              checked={value.scroll}
              onChange={(e) => setValue({ ...value, scroll: e.target.checked })}
            />
            Change iteration on scroll
          </label>
          <label>
            <input
              type="checkbox"
              checked={value.click}
              onChange={(e) => setValue({ ...value, click: e.target.checked })}
            />
            Scroll to comments on click
          </label>
        </div>
      }
      visible={open}
      interactive={true}
      onClickOutside={() => {
        setOpen(false)
      }}
    >
      <button
        className="settings-button btn-keyboard-shortcut"
        onClick={() => setOpen(!open)}
      >
        <Icon icon="settings" alt="View settings" />
      </button>
    </Tippy>
  )
}
