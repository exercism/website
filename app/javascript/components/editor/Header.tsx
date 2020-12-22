import React, { useCallback, forwardRef } from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { Icon } from '../common/Icon'
import { Settings } from './header/Settings'
import { ActionMore } from './header/ActionMore'

export const Header = ({ children }: { children: React.ReactNode }) => (
  <div className="header">{children}</div>
)

Header.Back = ({ exercisePath }: { exercisePath: string }) => (
  <a href={exercisePath} className="close-btn">
    <GraphicalIcon icon="arrow-left" />
    Exit Editor
  </a>
)

Header.Title = ({
  trackTitle,
  exerciseTitle,
}: {
  trackTitle: string
  exerciseTitle: string
}) => (
  <div className="title">
    <div className="track">{trackTitle}</div>
    <div className="divider">/</div>
    <div className="exercise">{exerciseTitle}</div>
  </div>
)

Header.ActionHints = () => (
  <button className="btn-small hints-btn">Hints</button>
)

Header.ActionKeyboardShortcuts = forwardRef<
  HTMLButtonElement,
  { onClick: () => void }
>(({ onClick }, ref) => {
  return (
    <button
      ref={ref}
      type="button"
      onClick={() => {
        onClick()
      }}
      className="keyboard-shortcuts-btn"
    >
      <Icon icon="keyboard" alt="Keyboard Shortcuts" />
    </button>
  )
})

Header.ActionSettings = Settings

Header.ActionMore = ActionMore
