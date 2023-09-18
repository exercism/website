import React, { useState } from 'react'
import { useDropdown } from '../../dropdowns/useDropdown'
import { EnableSolutionCommentsModal } from '../../modals/EnableSolutionCommentsModal'
import { DisableSolutionCommentsModal } from '../../modals/DisableSolutionCommentsModal'
import { GraphicalIcon } from '../../common'

type Links = {
  enable: string
  disable: string
}

type ModalId = 'enableComments' | 'disableComments'

export const Options = ({
  allowComments,
  links,
  onCommentsEnabled,
  onCommentsDisabled,
}: {
  allowComments: boolean
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
        <GraphicalIcon icon="settings" className="filter-textColor6" />
        <span>Options</span>
      </button>
      {open ? (
        <div {...panelAttributes} className="c-dropdown-generic-menu">
          <ul {...listAttributes}>
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
