import React, { createContext, useContext } from 'react'

type ProposedContextType = {
  uuid: string
  locale: string
  translation: string
  status: string
  llmInstructions: string
  proposals: Proposal[]
  currentUserId: string | number
}

const ProposedContext = createContext<ProposedContextType>(
  {} as ProposedContextType
)

export function ProposedProvider({
  children,
  value,
}: {
  children: React.ReactNode
  value: ProposedContextType
}) {
  return (
    <ProposedContext.Provider value={value}>
      {children}
    </ProposedContext.Provider>
  )
}

export function useProposedContext() {
  const context = useContext(ProposedContext)
  if (!context) {
    throw new Error('useProposedContext must be used within a ProposedProvider')
  }
  return context
}
