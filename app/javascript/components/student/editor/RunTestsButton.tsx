import React from 'react'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const RunTestsButton = ({ onClick }: { onClick: () => void }) => (
  <button type="button" onClick={onClick} className="btn-small-secondary">
    <GraphicalIcon icon="run-tests" />
    Run Tests
    <div className="kb-shortcut">F2</div>
  </button>
)
