import React from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'

export const RunTestsButton = ({ onClick }: { onClick: () => void }) => (
  <button type="button" onClick={onClick} className="btn-secondary btn-s">
    <GraphicalIcon icon="run-tests" />
    <span>Run Tests</span>
    <div className="kb-shortcut">F2</div>
  </button>
)
