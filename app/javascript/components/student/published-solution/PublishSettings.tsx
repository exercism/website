import React, { useState } from 'react'
import { useDropdown } from '../../dropdowns/useDropdown'
import {
  ChangePublishedIterationModal,
  RedirectType,
} from '../../modals/ChangePublishedIterationModal'
import { UnpublishSolutionModal } from '../../modals/UnpublishSolutionModal'
import { Iteration } from '../../types'
import { Icon } from '../../common'

type ModalId = 'changePublishedIteration' | 'unpublish'

type Links = {
  changeIteration: string
  unpublish: string
}

export const PublishSettings = ({
  redirectType,
  publishedIterationIdx,
  iterations,
  links,
}: {
  redirectType: RedirectType
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
        className="publish-settings-button btn-xs btn-enhanced"
      >
        <Icon icon="settings" alt="Publish settings" />
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
    </React.Fragment>
  )
}
