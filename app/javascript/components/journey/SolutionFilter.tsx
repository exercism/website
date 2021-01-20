import React from 'react'
import { usePanel } from '../../hooks/use-panel'
import { GraphicalIcon } from '../common'

type SolutionFilterOption = {
  value: string
  title: string
}

const OPTIONS: SolutionFilterOption[] = [
  {
    value: 'oop',
    title: 'OOP',
  },
  {
    value: 'functional',
    title: 'Functional',
  },
]

export const SolutionFilter = ({
  values,
  setFilter,
}: {
  values: string[]
  setFilter: (value: string[]) => void
}): JSX.Element => {
  const { open, setOpen, buttonRef, panelRef, styles, attributes } = usePanel()

  return (
    <React.Fragment>
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
            {OPTIONS.map((option) => {
              return (
                <div key={option.value}>
                  <label htmlFor={option.value}>{option.title}</label>
                  <input
                    type="checkbox"
                    id={option.value}
                    value={option.value}
                    onChange={() => setFilter([...values, option.value])}
                    checked={values.includes(option.value)}
                  />
                </div>
              )
            })}
          </div>
        ) : null}
      </div>
    </React.Fragment>
  )
}
