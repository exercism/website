import React, { useState } from 'react'
import { useDropdown } from '../dropdowns/useDropdown'
import { ChangePublishedIterationModal } from '../modals/ChangePublishedIterationModal'
import { UnpublishSolutionModal } from '../modals/UnpublishSolutionModal'
import { Iteration } from '../types'

type ModalId = 'changePublishedIteration' | 'unpublish'

export type Links = {
  changeIteration: string
  unpublish: string
}

export const PublishSettings = ({
  publishedIterationIdx,
  iterations,
  links,
}: {
  endpoint: string
  publishedIterationIdx: number | null
  iterations: readonly Iteration[]
  links: Links
}): JSX.Element => {
  const [openedModal, setOpenedModal] = useState<ModalId | null>(null)
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
              <button
                type="button"
                onClick={() => setOpenedModal('changePublishedIteration')}
              >
                Change published iteration
              </button>
            </li>
            <li {...itemAttributes(1)}>
              <button type="button" onClick={() => setOpenedModal('unpublish')}>
                Unpublish
              </button>
            </li>
          </ul>
        </div>
      ) : null}
      <ChangePublishedIterationModal
        endpoint={links.changeIteration}
        iterations={iterations}
        defaultIterationIdx={publishedIterationIdx}
        open={openedModal === 'changePublishedIteration'}
        onClose={() => setOpenedModal(null)}
        className="m-change-published-iteration"
      />
      <UnpublishSolutionModal
        endpoint={links.unpublish}
        open={openedModal === 'unpublish'}
        onClose={() => setOpenedModal(null)}
        className="m-unpublish-solution"
      />
    </React.Fragment>
  )
}
