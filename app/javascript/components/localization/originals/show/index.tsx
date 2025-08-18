import React from 'react'
import Icon from '@/components/common/Icon'
import { flagForLocale } from '@/utils/flag-for-locale'
import { Proposed } from './Proposed'
import { Unchecked } from './Unchecked'
import { Checked } from './Checked'

const OriginalsShowContext = React.createContext<OriginalsShowContextType>(
  {} as OriginalsShowContextType
)

export default function ({ original }: { original: Original }) {
  return (
    <OriginalsShowContext.Provider value={{ original }}>
      <Header />
      <Body />
    </OriginalsShowContext.Provider>
  )
}

function Header() {
  const { original } = React.useContext(OriginalsShowContext)
  return (
    <header className="header">
      <div className="lg-container container">
        <div className="close-btn">
          <Icon icon="close" className="c-icon" alt="Close" />
        </div>
        <div className="info">
          <div className="intro">You are editing translations for</div>
          <div className="key">{original.key}</div>
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
        <p className="text-16 mb-16">
          These are the locales you have opted into help translate. You can
          change your locales{' '}
          <a href="#" className="c-prominent-link --inline">
            here
          </a>
          .
        </p>
        {original.translations.map((translation, index) => {
          switch (translation.status) {
            case 'proposed': {
              // TODO: Get userId, work out a proper translation type
              return (
                <Proposed
                  // @ts-ignore
                  translation={translation}
                  currentUserId={1530}
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
        <div className="text-h3 mb-6">Original English</div>
        <p className="text-16 mb-6">
          This is the original English value. Your job is to make the locales as
          close to this in
          <strong className="font-semibold">meaning and tone</strong>
          as possible. Please do not change the meaning away from the original
          English.
        </p>
        <div className="locale-value mb-20">{original.value}</div>
        <div className="text-h4 mb-6">Usage</div>
        <p className="text-16">Context</p>
      </div>
    </div>
  )
}
