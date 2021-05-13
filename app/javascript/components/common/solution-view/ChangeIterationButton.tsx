import React from 'react'
import { usePanel } from '../../../hooks/use-panel'
import { ChangeIterationForm } from './ChangeIterationForm'
import { Iteration } from '../../types'

export const ChangeIterationButton = ({
  endpoint,
  publishedIterationIdx,
  iterations,
}: {
  endpoint: string
  publishedIterationIdx: number | null
  iterations: readonly Iteration[]
}): JSX.Element => {
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel({
    placement: 'top',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  return (
    <React.Fragment>
      <button
        type="button"
        onClick={() => setOpen(!open)}
        {...buttonAttributes}
      >
        Publish settings
      </button>
      {open ? (
        <div {...panelAttributes}>
          <ChangeIterationForm
            endpoint={endpoint}
            defaultIterationIdx={publishedIterationIdx}
            iterations={iterations}
            onCancel={() => {
              setOpen(false)
            }}
          />
        </div>
      ) : null}
    </React.Fragment>
  )
}
