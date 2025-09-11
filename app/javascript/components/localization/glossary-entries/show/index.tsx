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
          <div className="intro">You are editing glossary entry for</div>
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
    </div>
  )
}

function LHS() {
  const { glossaryEntry, currentUserId, links } = React.useContext(
    GlossaryEntriesShowContext
  )

  useLogger('render', glossaryEntry)
  return (
    <div className="translations mt-16 max-w-[800px]">
      <h2 className="text-h2 mb-4">Proposals</h2>
      <p className="text-p-base mb-16">
        These are the proposals suggested by either an LLM or other translators.
        Each proposal must be checked and then signed-off. Please{' '}
        <strong className="font-semibold">
          edit translations that are incorrect
        </strong>
        , which will put them in a queue for other reviewers to see, or mark
        them as checked/signed-off.
      </p>
      {renderShow(glossaryEntry, currentUserId)}
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
