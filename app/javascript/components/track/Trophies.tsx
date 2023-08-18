import React, { Dispatch, SetStateAction, useCallback, useState } from 'react'
import { useMutation } from 'react-query'
import { assetUrl, sendRequest } from '@/utils'
import { GraphicalIcon } from '../common'
import { Modal } from '../modals'
import { GenericTooltip } from '../misc/ExercismTippy'

export type TrophyStatus = 'not_earned' | 'unrevealed' | 'revealed'

export type TrophyLinks = {
  reveal?: string
}

export type Trophy = {
  name: string
  criteria: string
  successMessage: string
  iconName: string
  status: TrophyStatus
  links: TrophyLinks
}

export type TrophiesProps = {
  trophies: readonly Trophy[]
}

export function Trophies({ trophies }: TrophiesProps): JSX.Element {
  const [modalOpen, setModalOpen] = useState(false)
  const [highlightedTrophy, setHighlightedTrophy] = useState<Trophy | null>(
    null
  )
  const [currentTrophies, setCurrentTrophies] = useState(trophies)
  const updateTrophy = useCallback(
    (trophy: Trophy) => {
      setCurrentTrophies(
        currentTrophies.map((currentTrophy) =>
          currentTrophy === trophy ? trophy : currentTrophy
        )
      )
    },
    [setCurrentTrophies, currentTrophies]
  )

  return (
    <div className="trophies">
      {currentTrophies.map((trophy) => (
        <Trophy
          key={trophy.name}
          trophy={trophy}
          setHighlightedTrophy={setHighlightedTrophy}
          setModalOpen={setModalOpen}
          updateTrophy={updateTrophy}
        />
      ))}
      <Modal open={modalOpen} celebratory onClose={() => setModalOpen(false)}>
        <div className="flex flex-col items-center">
          {highlightedTrophy && (
            <>
              <h2 className="text-h2 mb-12">
                {highlightedTrophy.successMessage}
              </h2>
              <div className="trophy acquired">
                <TrophyIcon trophy={highlightedTrophy} />
                <div className="title">{highlightedTrophy.name}</div>
              </div>
              <p className="text-p-base mt-16">{highlightedTrophy.criteria}</p>
            </>
          )}
        </div>
      </Modal>
    </div>
  )
}

const TrophyIcon = ({ trophy }: { trophy: Trophy }): JSX.Element => {
  return (
    <div className="icon">
      <GraphicalIcon
        icon={trophy.iconName}
        category="graphics"
        width={128}
        height={128}
      />
    </div>
  )
}

const Trophy = ({
  trophy,
  setHighlightedTrophy,
  setModalOpen,
  updateTrophy,
}: {
  trophy: Trophy
  setHighlightedTrophy: Dispatch<SetStateAction<Trophy | null>>
  setModalOpen: Dispatch<SetStateAction<boolean>>
  updateTrophy: (trophy: Trophy) => void
}): JSX.Element => {
  switch (trophy.status) {
    case 'not_earned':
      return <NotEarnedTrophy key={trophy.name} trophy={trophy} />
    case 'unrevealed':
      return (
        <UnrevealedTrophy
          key={trophy.name}
          trophy={trophy}
          setHighlightedTrophy={setHighlightedTrophy}
          setModalOpen={setModalOpen}
          updateTrophy={updateTrophy}
        />
      )
    case 'revealed':
      return (
        <RevealedTrophy
          key={trophy.name}
          trophy={trophy}
          setHighlightedTrophy={setHighlightedTrophy}
          setModalOpen={setModalOpen}
        />
      )
  }
}

const RevealedTrophy = ({
  trophy,
  setHighlightedTrophy,
  setModalOpen,
}: {
  trophy: Trophy
  setHighlightedTrophy: Dispatch<SetStateAction<Trophy | null>>
  setModalOpen: Dispatch<SetStateAction<boolean>>
}): JSX.Element => {
  const onClick = useCallback(() => {
    setHighlightedTrophy(trophy)
    setModalOpen(true)
  }, [setHighlightedTrophy, setModalOpen])

  return (
    <GenericTooltip content={trophy.successMessage}>
      <button className="trophy acquired" onClick={() => onClick()}>
        <TrophyIcon trophy={trophy} />
        <div className="title">{trophy.name}</div>
      </button>
    </GenericTooltip>
  )
}

const UnrevealedTrophy = ({
  trophy,
  setHighlightedTrophy,
  setModalOpen,
  updateTrophy,
}: {
  trophy: Trophy
  setHighlightedTrophy: Dispatch<SetStateAction<Trophy | null>>
  setModalOpen: Dispatch<SetStateAction<boolean>>
  updateTrophy: (trophy: Trophy) => void
}): JSX.Element => {
  const [showError, setShowError] = useState(false)
  const [mutation] = useMutation(
    () => {
      if (!trophy.links.reveal) {
        throw new Error('Reveal link is not available')
      }
      const { fetch } = sendRequest({
        endpoint: trophy.links.reveal,
        method: 'PATCH',
        body: '',
      })

      return fetch
    },
    {
      onSuccess: () => {
        trophy.status = 'revealed'
        updateTrophy(trophy)
        setHighlightedTrophy(trophy)
        setModalOpen(true)
        setShowError(false)
      },
      onError: () => setShowError(true),
    }
  )

  return (
    <button className="trophy revealable" onClick={() => mutation()}>
      <TrophyIcon trophy={trophy} />
      <div
        className="shimmer"
        style={{
          backgroundImage: `url(${assetUrl(
            `graphics/${trophy.iconName}.svg`
          )})`,
        }}
      />
      <div className="title !text-textColor1">Click to Reveal</div>
      {showError && (
        <div className="c-alert--danger">Failed to reveal trophy</div>
      )}
    </button>
  )
}

const NotEarnedTrophy = ({ trophy }: { trophy: Trophy }): JSX.Element => {
  return (
    <GenericTooltip content={trophy.criteria}>
      <div className="trophy not-acquired">
        <TrophyIcon trophy={trophy} />
        <div className="title">{trophy.name}</div>
      </div>
    </GenericTooltip>
  )
}
