import React from 'react'
import { GraphicalIcon } from '../../common'

export const Header = (): JSX.Element => {
  return (
    <header className="flex items-center mb-12">
      <h2 className="text-h4">Write a comment</h2>
      <button className="btn-s text-14 text-textColor6 ml-auto">
        <GraphicalIcon icon="settings" />
        <span>Options</span>
      </button>
    </header>
  )
}
