import React, { useState } from 'react'
import { useDropdown } from '../../dropdowns/useDropdown'
import {
  ChangePublishedIterationModal,
  RedirectType,
} from '../../modals/ChangePublishedIterationModal'
import { UnpublishSolutionModal } from '../../modals/UnpublishSolutionModal'
import { EnableSolutionCommentsModal } from '../../modals/EnableSolutionCommentsModal'
import { DisableSolutionCommentsModal } from '../../modals/DisableSolutionCommentsModal'
import { Iteration } from '../../types'
import { GraphicalIcon } from '../../common'

type Links = {
  changeIteration: string
  unpublish: string
  enable: string
  disable: string
}

type ModalId =
  | 'changePublishedIteration'
  | 'unpublish'
  | 'enableComments'
  | 'disableComments'

export const Options = ({
  allowComments,
  redirectType,
  publishedIterationIdx,
  iterations,
  links,
  onCommentsEnabled,
  onCommentsDisabled,
}: {
  allowComments: boolean
  redirectType: RedirectType
  publishedIterationIdx: number | null
  iterations: readonly Iteration[]
  links: Links
  onCommentsEnabled: () => void
  onCommentsDisabled: () => void
}): JSX.Element => {
  const [openedModal, setOpenedModal] = useState<ModalId | null>(null)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(3, undefined, {
    placement: 'top-end',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [10, 8],
        },
      },
    ],
  })

  return (
    <React.Fragment>
      <button
        {...buttonAttributes}
        className="btn-s text-14 text-textColor6 ml-auto"
      >
        <GraphicalIcon icon="settings" />
        <span>Options</span>
      </button>
      {open ? (
        <div {...panelAttributes} className="c-dropdown-generic-menu">
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <button
                type="button"
                onClick={() => setOpenedModal('changePublishedIteration')}
              >
                Change published iterations…
              </button>
            </li>
            <li {...itemAttributes(1)}>
              <button type="button" onClick={() => setOpenedModal('unpublish')}>
                Unpublish solution…
              </button>
            </li>
            <li {...itemAttributes(1)}>
              {allowComments ? (
                <button
                  type="button"
                  onClick={() => setOpenedModal('disableComments')}
                >
                  Disable comments…
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => setOpenedModal('enableComments')}
                >
                  Enable comments…
                </button>
              )}
            </li>
          </ul>
        </div>
      ) : null}
      <ChangePublishedIterationModal
        endpoint={links.changeIteration}
        redirectType={redirectType}
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
      <EnableSolutionCommentsModal
        endpoint={links.enable}
        open={openedModal === 'enableComments'}
        onClose={() => setOpenedModal(null)}
        onSuccess={onCommentsEnabled}
      />
      <DisableSolutionCommentsModal
        endpoint={links.disable}
        open={openedModal === 'disableComments'}
        onClose={() => setOpenedModal(null)}
        onSuccess={onCommentsDisabled}
      />
    </React.Fragment>
  )
}
