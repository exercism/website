/// <reference path="../types.d.ts" />
import React from 'react'
import Icon from '@/components/common/Icon'
import { Unchecked } from './Unchecked'
import { Checked } from './Checked'
import { Proposed } from './Proposed'
import { useLogger } from '@/hooks'
import { Toaster } from 'react-hot-toast'

export const GlossaryEntriesShowContext =
  React.createContext<GlossaryEntriesShowContextType>(
    {} as GlossaryEntriesShowContextType
  )

export default function ({
  glossaryEntry,
  currentUserId,
  links,
}: GlossaryEntriesShowProps) {
  return (
    <GlossaryEntriesShowContext.Provider
      value={{ glossaryEntry, currentUserId, links }}
    >
      <Header />
      <Body />
      <Toaster />
    </GlossaryEntriesShowContext.Provider>
  )
}

function Header() {
  const { glossaryEntry, links } = React.useContext(GlossaryEntriesShowContext)
  return (
    <header className="header">
      <div className="lg-container container">
        <a href={links.glossaryEntriesListPage} className="close-btn">
          <Icon icon="close" className="c-icon" alt="Close" />
        </a>
        <div className="info">
          <div className="intro">You are editing the glossary entry for</div>
          <div className="key">
            {glossaryEntry.term} ({glossaryEntry.locale})
          </div>
        </div>
      </div>
    </header>
  )
}

function Body() {
  return (
    <div className="lg-container body-container">
      <LHS />
      <RHS />
    </div>
  )
}

function LHS() {
  const { glossaryEntry, currentUserId } = React.useContext(
    GlossaryEntriesShowContext
  )

  useLogger('render', glossaryEntry)
  return (
    <div className="translations mt-16 max-w-[800px]">
      <h2 className="text-h2 mb-4">Proposal</h2>
      <p className="text-p-base mb-16">
        This proposal was suggested by an LLM or another translator. It needs to
        be reviewed and signed off. Please{' '}
        <strong className="font-semibold">
          edit any incorrect translations.
        </strong>{' '}
        Your changes will be placed in a queue for another reviewer, or mark it
        as checked and signed off.
      </p>
      {renderShow(glossaryEntry, currentUserId)}
    </div>
  )
}

function RHS() {
  const { glossaryEntry } = React.useContext(GlossaryEntriesShowContext)
  return (
    <div className="rhs">
      <div className="original">
        <h2 className="text-h3 mb-6">The Entry</h2>
        <p>
          Your job is to make the translation as close to the original English
          in <strong className="font-semibold">meaning and tone</strong> as
          possible, considering how it is used on the site.
        </p>
        <p>
          <strong className="font-semibold">
            Please be careful not to change the meaning of the original English
          </strong>
          . If you believe the original English is wrong, please{' '}
          <a
            href="https://forum.exercism.org/c/exercism/i18n/695"
            className="c-prominent-link --inline"
          >
            start a discussion on the forum
          </a>
          .
        </p>

        <div className="c-textblock-note">
          <div className="c-textblock-header">How this term is used</div>
          <div className="c-textblock-content">
            <p>{glossaryEntry.llmInstructions}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

function renderShow(
  glossaryEntry: GlossaryEntry,
  currentUserId: string | number
) {
  switch (glossaryEntry.status) {
    case 'proposed': {
      return (
        <Proposed
          key={glossaryEntry.uuid}
          uuid={glossaryEntry.uuid}
          locale={glossaryEntry.locale}
          translation={glossaryEntry.translation}
          status={glossaryEntry.status}
          llmInstructions={glossaryEntry.llmInstructions}
          proposals={glossaryEntry.proposals || []}
          currentUserId={currentUserId}
        />
      )
    }

    case 'unchecked': {
      return <Unchecked key={glossaryEntry.uuid} translation={glossaryEntry} />
    }
    case 'checked': {
      return <Checked key={glossaryEntry.uuid} translation={glossaryEntry} />
    }
  }
}
