import React, { useState } from 'react'
import { useDropdown } from '../dropdowns/useDropdown'
import { ChangePublishedIterationModal } from '../modals/ChangePublishedIterationModal'
import { Iteration } from '../types'

export const PublishSettings = ({
  endpoint,
  publishedIterationIdx,
  iterations,
}: {
  endpoint: string
  publishedIterationIdx: number | null
  iterations: readonly Iteration[]
}): JSX.Element => {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(2, undefined, {
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
      <button {...buttonAttributes}>Publish settings</button>
      {open ? (
        <div {...panelAttributes}>
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <button type="button" onClick={() => setIsModalOpen(true)}>
                Change published iteration
              </button>
            </li>
          </ul>
        </div>
      ) : null}
      <ChangePublishedIterationModal
        endpoint={endpoint}
        iterations={iterations}
        defaultIterationIdx={publishedIterationIdx}
        open={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        className="m-change-published-iteration"
      />
    </React.Fragment>
  )
}
