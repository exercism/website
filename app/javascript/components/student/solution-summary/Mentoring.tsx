import React from 'react'
import ReactDOM from 'react-dom'
import { GraphicalIcon, Icon } from '../../common'
import { usePanel } from '../../../hooks/use-panel'
import { MentoringDropdown } from '../MentoringDropdown'
import { MentorDiscussion } from '../../types'

type Links = {
  learnMoreAboutMentoringArticle: string
  shareMentoring: string
  requestMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export const Mentoring = ({
  hasMentorDiscussionInProgress,
  hasMentorRequestPending,
  discussions,
  links,
}: {
  hasMentorDiscussionInProgress: boolean
  hasMentorRequestPending: boolean
  discussions: readonly MentorDiscussion[]
  links: Links
}): JSX.Element => {
  return (
    <div className="mentoring">
      <GraphicalIcon icon="graphic-mentoring-screen" className="header-icon" />
      <h3>Get mentored by a human</h3>
      <p>
        On average, students iterate a further 3.5 times when mentored on a
        solution.
      </p>
      <MentoringComboButton
        hasMentorDiscussionInProgress={hasMentorDiscussionInProgress}
        hasMentorRequestPending={hasMentorRequestPending}
        discussions={discussions}
        links={links}
      />
      <a href={links.learnMoreAboutMentoringArticle} className="learn-more">
        Learn more
        <Icon icon="external-link" alt="Opens in new tab" />
      </a>
    </div>
  )
}

const MentoringComboButton = ({
  hasMentorDiscussionInProgress,
  hasMentorRequestPending,
  discussions,
  links,
}: {
  hasMentorDiscussionInProgress: boolean
  hasMentorRequestPending: boolean
  discussions: readonly MentorDiscussion[]
  links: {
    requestMentoring: string
    shareMentoring: string
    pendingMentorRequest: string
    inProgressDiscussion?: string
  }
}) => {
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

  return (
    /* TODO: Extract into a common component in the future */
    <div className="c-combo-button">
      {hasMentorDiscussionInProgress && links.inProgressDiscussion ? (
        <a href={links.inProgressDiscussion} className="--editor-segment">
          Continue mentoring
        </a>
      ) : hasMentorRequestPending ? (
        <a href={links.pendingMentorRequest} className="--editor-segment">
          View mentoring request
        </a>
      ) : (
        <a href={links.requestMentoring} className="--editor-segment">
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
