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

  return (
    <div className="trophies">
      {trophies.map((trophy) => (
        <Trophy
          key={trophy.name}
          trophy={trophy}
          setHighlightedTrophy={setHighlightedTrophy}
          setModalOpen={setModalOpen}
        />
      ))}
      <Modal open={modalOpen} celebratory onClose={() => setModalOpen(false)}>
        <div className="flex flex-col items-center">
          <h2 className="text-h2 mb-12">{highlightedTrophy?.successMessage}</h2>

          {highlightedTrophy && (
            <Trophy
              trophy={highlightedTrophy}
              disabled
              setHighlightedTrophy={setHighlightedTrophy}
              setModalOpen={setModalOpen}
            />
          )}
          <p className="text-p-base mt-16">{highlightedTrophy?.criteria}</p>
        </div>
      </Modal>
    </div>
  )
}

const statusToClassName: Record<TrophyStatus, string> = {
  not_earned: 'not-acquired',
  revealed: 'acquired',
  unrevealed: 'revealable',
}

const Trophy = ({
  trophy,
  setHighlightedTrophy,
  setModalOpen,
  disabled = false,
}: {
  trophy: Trophy
  setHighlightedTrophy: Dispatch<SetStateAction<Trophy | null>>
  setModalOpen: Dispatch<SetStateAction<boolean>>
  disabled?: boolean
}): JSX.Element => {
  const [trophyStatus, setTrophyStatus] = useState<TrophyStatus>(trophy.status)
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
        setHighlightedTrophy(trophy)
        setModalOpen(true)
        setTrophyStatus('revealed')
        setShowError(false)
      },
      onError: () => setShowError(true),
    }
  )

  const handleReveal = useCallback(() => {
    if (trophyStatus === 'unrevealed') {
      mutation()
    } else if (trophyStatus === 'revealed') {
      setHighlightedTrophy(trophy)
      setModalOpen(true)
    }
  }, [mutation, setHighlightedTrophy, setModalOpen, trophy, trophyStatus])

  return (
    <button
      className={`trophy ${statusToClassName[trophyStatus]}`}
      onClick={handleReveal}
      disabled={trophyStatus === 'not_earned' || disabled}
    >
      <div className="icon">
        <GraphicalIcon
          icon={trophy.iconName}
          category="graphics"
          width={128}
          height={128}
        />
      </div>
      {trophyStatus === 'unrevealed' ? (
        <>
          <div
            className="shimmer"
            style={{
              backgroundImage: `url(${assetUrl(
                `graphics/${trophy.iconName}.svg`
              )})`,
            }}
          />
          <div className="title !text-textColor1">Click to Reveal</div>
        </>
      ) : (
        <GenericTooltip content={trophy.criteria}>
          <div className="title">{trophy.name}</div>
        </GenericTooltip>
      )}
      {showError && (
        <div className="c-alert--danger">Failed to reveal trophy</div>
      )}
    </button>
  )
}
