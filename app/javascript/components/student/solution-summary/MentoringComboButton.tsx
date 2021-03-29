import React from 'react'
import ReactDOM from 'react-dom'
import { usePanel } from '../../../hooks/use-panel'
import { MentoringDropdown } from '../MentoringDropdown'
import { GraphicalIcon } from '../../common'
import { MentorDiscussion } from '../../types'

type Links = {
  requestMentoring: string
  shareMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export const MentoringComboButton = ({
  hasMentorDiscussionInProgress,
  hasMentorRequestPending,
  discussions,
  className = '',
  links,
}: {
  hasMentorDiscussionInProgress: boolean
  hasMentorRequestPending: boolean
  discussions: readonly MentorDiscussion[]
  className?: string
  links: Links
}): JSX.Element => {
  const {
    open,
    setOpen,
    setButtonElement,
    setPanelElement,
    styles,
    attributes,
  } = usePanel({
    placement: 'bottom-end',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 14],
        },
      },
    ],
  })

  const classNames = ['c-combo-button', className]

  return (
    /* TODO: Extract into a common component in the future */
    <div className={classNames.join(' ')}>
      {hasMentorDiscussionInProgress && links.inProgressDiscussion ? (
        <a href={links.inProgressDiscussion} className="--primary-segment">
          Continue mentoring
        </a>
      ) : hasMentorRequestPending ? (
        <a href={links.pendingMentorRequest} className="--primary-segment">
          View mentoring request
        </a>
      ) : (
        <a href={links.requestMentoring} className="--primary-segment">
          Request mentoring
        </a>
      )}
      <button
        className="--dropdown-segment"
        onClick={() => {
          setOpen(!open)
        }}
        ref={setButtonElement}
      >
        <GraphicalIcon icon="chevron-down" />
      </button>
      <MentoringPanel
        setPanelElement={setPanelElement}
        open={open}
        styles={styles}
        attributes={attributes}
      >
        <MentoringDropdown
          hasMentorDiscussionInProgress={hasMentorDiscussionInProgress}
          discussions={discussions}
          links={{ share: links.shareMentoring }}
        />
      </MentoringPanel>
    </div>
  )
}

type PanelProps = {
  open: boolean
  styles: { [key: string]: React.CSSProperties }
  attributes: {
    [key: string]: {
      [key: string]: string
    }
  }
  setPanelElement: React.Dispatch<React.SetStateAction<HTMLDivElement | null>>
}

const MentoringPanel = ({
  open,
  styles,
  setPanelElement,
  attributes,
  children,
}: React.PropsWithChildren<PanelProps>) => {
  const portalContainer = document.getElementById('portal-container')

  if (!portalContainer) {
    throw new Error('No portal container found')
  }

  return ReactDOM.createPortal(
    <div ref={setPanelElement} style={styles.popper} {...attributes.popper}>
      {open ? children : null}
    </div>,
    portalContainer
  )
}
