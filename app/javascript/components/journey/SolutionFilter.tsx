import React from 'react'
import { usePanel } from '../../hooks/use-panel'
import { GraphicalIcon } from '../common'
import { SolutionFilterOption } from './SolutionsList'

export const SolutionFilter = ({
  options,
  value,
  setFilter,
}: {
  options: SolutionFilterOption[]
  value: string[]
  setFilter: (value: string[]) => void
}): JSX.Element => {
  const {
    open,
    setOpen,
    buttonRef,
    panelRef,
    componentRef,
    styles,
    attributes,
  } = usePanel()

  return (
    <div ref={componentRef}>
      <button
        ref={buttonRef}
        className="--filter-btn"
        onClick={() => {
          setOpen(!open)
        }}
      >
        Filter By
        {open ? (
          <GraphicalIcon icon="chevron-down" />
        ) : (
          <GraphicalIcon icon="chevron-up" />
        )}
      </button>
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <div>
            {options.map((option) => {
              return (
                <div key={option.value}>
                  <label htmlFor={option.value}>{option.title}</label>
                  <input
                    type="checkbox"
                    id={option.value}
                    value={option.value}
                    onChange={() => setFilter([...value, option.value])}
                    checked={value.includes(option.value)}
                  />
                </div>
              )
            })}
          </div>
        ) : null}
      </div>
    </div>
  )
}
