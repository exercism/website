import React from 'react'

type EditActionsProps = {
  onSave: () => void
  onCancel: () => void
}

export function EditActions({ onSave, onCancel }: EditActionsProps) {
  return (
    <div className="flex gap-8 items-center">
      <button type="button" className="btn-s btn-default" onClick={onCancel}>
        Cancel
      </button>
      <button type="button" className="btn-s btn-primary" onClick={onSave}>
        Save
      </button>
    </div>
  )
}
