import React from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { Icon } from '../common/Icon'
import { Settings } from './header/Settings'

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
    <div className="exeercise">{exerciseTitle}</div>
  </div>
)

Header.ActionHints = () => (
  <button className="btn-small hints-btn">Hints</button>
)

Header.ActionKeyboardShortcuts = () => (
  <button className="keyboard-shortcuts-btn">
    <Icon icon="keyboard" alt="Keyboard Shortcuts" />
  </button>
)

Header.ActionSettings = Settings

Header.ActionMore = () => (
  <button className="more-btn">
    <Icon icon="more-horizontal" alt="Open more options" />
  </button>
)
