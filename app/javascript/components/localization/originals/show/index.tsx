import React from 'react'
import Icon from '@/components/common/Icon'
import { Proposed } from './Proposed'
import { Unchecked } from './Unchecked'
import { Checked } from './Checked'

export const OriginalsShowContext =
  React.createContext<OriginalsShowContextType>({} as OriginalsShowContextType)

export default function ({
  original,
  currentUserId,
  links,
}: OriginalsShowProps) {
  return (
    <OriginalsShowContext.Provider value={{ original, currentUserId, links }}>
      <Header />
      <Body />
    </OriginalsShowContext.Provider>
  )
}

function Header() {
  const { original, links } = React.useContext(OriginalsShowContext)
  return (
    <header className="header">
      <div className="lg-container container">
        <a href={links.originalsListPage} className="close-btn">
          <Icon icon="close" className="c-icon" alt="Close" />
        </a>
        <div className="info">
          <div className="intro">You are editing translations for</div>
          <div className="key">
            {original.title} ({original.prettyType})
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
  const { original } = React.useContext(OriginalsShowContext)
  return (
    <div className="lhs">
      <div className="translations">
        <div className="text-h3 mb-6">Your Locales</div>
        <p className="text-16 mb-16 leading-140">
          These are the locales you have opted into help translate. You can{' '}
          <a href="#" className="c-prominent-link --inline">
            change your locales here
          </a>
          .
        </p>
        {original.translations.map((translation, index) => {
          switch (translation.status) {
            case 'proposed': {
              return (
                <Proposed
                  // @ts-ignore
                  translation={translation}
                  key={index}
                />
              )
            }

            case 'unchecked': {
              return <Unchecked translation={translation} key={index} />
            }
            case 'checked': {
              return <Checked translation={translation} key={index} />
            }
          }
        })}
      </div>
    </div>
  )
}

function RHS() {
  const { original } = React.useContext(OriginalsShowContext)
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

        <h3 className="text-h4 mb-6">The English Version</h3>
        <div className="locale-value mb-20">{original.value}</div>

        <h3 className="text-h4 mb-6">How it's used</h3>
        <p className="text-16">{original.usageDetails}</p>
      </div>
    </div>
  )
}
