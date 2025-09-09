type GlossaryEntriesListContextType = Pick<
  GlossaryEntriesListProps,
  'links' | 'glossaryEntries'
> & {
  setCriteria: (criteria: string) => void
  setPage: (page: number) => void
  resolvedData?: GlossaryEntriesListData
  request: import('@/hooks/use-list').ListState
  setQuery: (query: Record<string, any>) => void
  isFetching: boolean
  status: 'pending' | 'error' | 'success'
  error?: unknown
}

type Proposal = {
  uuid: string
  type: string
  status: string
  term: string
  translation: string
  proposerId: string | number
  llmInstructions: string
  reviewerId?: string | number | null
  llmFeedback?: string
}

type GlossaryEntry = {
  uuid: string
  locale: string
  term: string
  translation: string
  status: 'unchecked' | 'approved' | 'rejected' | 'proposed'
  llmInstructions: string
  proposalsCount: number
  proposals?: Proposal[]
}

type GlossaryEntriesListData = {
  meta: {
    currentPage: number
    totalPages: number
    totalCount: number
    unscopedTotal: number
  }
  results: GlossaryEntry[]
}

type GlossaryEntriesListProps = {
  glossaryEntries: GlossaryEntry[]
  request: {
    endpoint: string
    query?: Record<string, any>
    options: {
      initialData: GlossaryEntriesListData
    }
  }
  links?: { localizationGlossaryEntriesPath: string; endpoint: string }
}

// {
//   "glossaryEntry": {
//       "uuid": "f1ebf3cd-c7f0-4c89-bb67-aa90b0cc50c1",
//       "locale": "de",
//       "term": "subscription",
//       "translation": "Abonnement",
//       "status": "unchecked",
//       "llmInstructions": "A recurring monthly donation to Exercism. Use the term for subscription or recurring payment",
//       "proposals": []
//   },
//   "currentUserId": 1530,
//   "links": {
//       "glossaryEntriesListPage": "http://local.exercism.io:3020/localization/glossary_entries",
//       "approveLlmTranslation": "http://local.exercism.io:3020/api/v2/localization/translations/f1ebf3cd-c7f0-4c89-bb67-aa90b0cc50c1/approve_llm_version",
//       "createProposal": "http://local.exercism.io:3020/api/v2/localization/glossary_entries/GLOSSARY_ENTRY_ID/proposals?id=ID",
//       "approveProposal": "http://local.exercism.io:3020/api/v2/localization/glossary_entries/GLOSSARY_ENTRY_ID/proposals/ID/approve",
//       "rejectProposal": "http://local.exercism.io:3020/api/v2/localization/glossary_entries/GLOSSARY_ENTRY_ID/proposals/ID/reject",
//       "updateProposal": "http://local.exercism.io:3020/api/v2/localization/glossary_entries/GLOSSARY_ENTRY_ID/proposals/ID"
//   }
// }
type GlossaryEntriesShowProps = {
  glossaryEntry: GlossaryEntry
  currentUserId: number
  links: GlossaryEntriesShowLinks
}

type GlossaryEntriesShowLinks = {
  glossaryEntriesListPage: string
  approveLlmTranslation: string
  createProposal: string
  approveProposal: string
  rejectProposal: string
  updateProposal: string
}

type GlossaryEntriesShowContextType = GlossaryEntriesShowProps
