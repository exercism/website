/// <reference path="../types.d.ts" />
import React from 'react'
import Icon from '@/components/common/Icon'
import { Unchecked } from './Unchecked'
import { Checked } from './Checked'

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
      <RHS />
    </div>
  )
}

function LHS() {
  const { glossaryEntry } = React.useContext(GlossaryEntriesShowContext)
  return (
    <div className="lhs">
      <div className="translations">
        <div className="text-h3 mb-6">Your Locales</div>
        <p className="text-16 mb-16 leading-140">
          These are the locales you have opted into help translate. You can{' '}
          {/* TODO: Add link here */}
          <a href="#" className="c-prominent-link --inline">
            change your locales here
          </a>
          .
        </p>
        {glossaryEntry.status === 'unchecked' && (
          <Unchecked translation={glossaryEntry} key={glossaryEntry.uuid} />
        )}
        {(glossaryEntry.status === 'approved' ||
          glossaryEntry.status === 'rejected') && (
          <Checked translation={glossaryEntry} key={glossaryEntry.uuid} />
        )}
      </div>
    </div>
  )
}

function RHS() {
  const { glossaryEntry } = React.useContext(GlossaryEntriesShowContext)
  return (
    <div className="rhs">
      <div className="original">
        <h2 className="text-h3 mb-6">The Original</h2>
        <p className="text-16 mb-4 leading-140">
          Your job is to make the locales as close to the original English in{' '}
          <strong className="font-semibold">meaning and tone</strong> as
          possible, considering how it is used in the site.{' '}
        </p>
        <p className="text-16 mb-8 leading-140">
          <strong className="font-semibold">
            Please be careful not change the meaning from the original English
          </strong>
          . If you feel the original English is wrong, please{' '}
          <a
            href="https://forum.exercism.org/c/exercism/i18n/695"
            className="c-prominent-link --inline"
          >
            start a discussion on the forum.
          </a>
        </p>

        <h3 className="text-h4 mb-6">The Term</h3>
        <div className="locale-value mb-20">{glossaryEntry.term}</div>

        <h3 className="text-h4 mb-6">LLM Instructions</h3>
        <p className="text-16">{glossaryEntry.llmInstructions}</p>
      </div>
    </div>
  )
}
