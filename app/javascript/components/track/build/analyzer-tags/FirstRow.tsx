import React from 'react'

export function FirstRow(): JSX.Element {
  return (
    <div className="record-row sticky z-1 lg:top-0 top-[65px]">
      <div className="record-name" />
      <div className="record-value">
        <div className="record-element">Tag</div>
        <div className="record-element justify-end">Enabled</div>
        <div className="record-element justify-end">Filterable</div>
        <div className="record-element justify-end">Num Solutions</div>
      </div>
    </div>
  )
}
