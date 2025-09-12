import React, { createContext, useCallback, useMemo, useState } from 'react'
import { useProposedContext } from './ProposedContext'
import { ProposalDescription } from './ProposalDescription'
import { FeedbackBlock } from './FeedbackBlock'
import { ProposalActions } from './ProposalActions'
import { EditActions } from './EditActions'

type ProposalCardContextType = {
  editMode: boolean
  setEditMode: (editMode: boolean) => void
}

const ProposalCardContext = createContext<ProposalCardContextType>(
  {} as ProposalCardContextType
)

type ProposalCardProps = {
  proposal: Proposal
  isMultiple: boolean
}

export function ProposalCard({ proposal, isMultiple }: ProposalCardProps) {
  const { currentUserId, locale } = useProposedContext()
  const isOwn = String(proposal.proposerId) === String(currentUserId)

  const cardClasses = isMultiple
    ? 'border-1 border-borderColor5 p-12 rounded-8 bg-backgroundColorF shadow-keystroke'
    : ''

  const textAreaRef = React.useRef<HTMLTextAreaElement>(null)
  const [editMode, setEditMode] = useState(false)
  const [proposalValue, setProposalValue] = useState(proposal.translation)
  const [editorValue, setEditorValue] = useState(proposal.translation)

  const hasBeenEdited = useMemo(() => {
    return proposalValue !== proposal.translation
  }, [proposalValue, proposal.translation])

  const onSaveEditing = useCallback(() => {
    setProposalValue(editorValue)
    setEditMode(false)
  }, [editorValue])

  const onCancelEditing = useCallback(() => {
    setEditMode(false)
    setEditorValue(proposalValue)
  }, [proposalValue])

  const onResetChanges = useCallback(() => {
    setEditorValue(proposal.translation)
    setProposalValue(proposal.translation)
  }, [proposal.translation])

  const onEditMode = useCallback(() => {
    setEditMode(true)
    setTimeout(() => {
      if (textAreaRef.current) {
        textAreaRef.current.focus()
        textAreaRef.current.setSelectionRange(
          textAreaRef.current.value.length,
          textAreaRef.current.value.length
        )
      }
    }, 0)
  }, [])

  return (
    <ProposalCardContext.Provider value={{ editMode, setEditMode }}>
      <div className={cardClasses} data-proposal-id={proposal.uuid}>
        {!isMultiple && <ProposalDescription locale={locale} />}

        {editMode ? (
          <textarea
            ref={textAreaRef}
            className="local-value mb-12 p-16 w-full"
            rows={1}
            value={editorValue}
            onChange={(e) => setEditorValue(e.target.value)}
            aria-label="Translation"
          />
        ) : (
          <div className="locale-value mb-12 !bg-white">{proposalValue}</div>
        )}

        {proposal.llmFeedback && (
          <FeedbackBlock feedback={proposal.llmFeedback} />
        )}

        {editMode ? (
          <EditActions onSave={onSaveEditing} onCancel={onCancelEditing} />
        ) : (
          <ProposalActions
            proposal={proposal}
            isOwn={isOwn}
            proposalValue={proposalValue}
            onResetChanges={onResetChanges}
            hasBeenEdited={hasBeenEdited}
            onEditMode={onEditMode}
          />
        )}
      </div>
    </ProposalCardContext.Provider>
  )
}
