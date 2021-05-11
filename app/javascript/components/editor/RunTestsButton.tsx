import React from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const RunTestsButton = (
  props: React.ButtonHTMLAttributes<HTMLButtonElement>
): JSX.Element => (
  <button type="button" className="btn-enhanced btn-s" {...props}>
    <GraphicalIcon icon="run-tests" />
    <span>Run Tests</span>
    <div className="kb-shortcut">F2</div>
  </button>
)
