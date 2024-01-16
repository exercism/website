import { useState, useEffect, useCallback } from 'react'
import { QueryStatus } from '@tanstack/react-query'
import { useSettingsMutation } from '../useSettingsMutation'
import { CommentsPreferenceFormProps } from './CommentsPreferenceForm'

type ExtendedQueryStatus = QueryStatus | 'idle'
type useCommentPreferencesFormReturns = {
  commentStatusPhrase: string
  mutationsStatus: ExtendedQueryStatus
  mutationsError: unknown
  successId: number
  allowCommentsByDefault: boolean
  numPublished: number
  numCommentsEnabled: number
  handleSubmit: (e: React.FormEvent) => void
  handleCommentsPreferenceChange: (e: React.FormEvent) => void
  enableAllMutation: () => void
  disableAllMutation: () => void
}

export function useCommentsPreferenceForm({
  currentPreference,
  numPublishedSolutions,
  numSolutionsWithCommentsEnabled,
  links,
}: Omit<
  CommentsPreferenceFormProps,
  'label'
>): useCommentPreferencesFormReturns {
  const [allowCommentsByDefault, setAllowCommentsByDefault] =
    useState(currentPreference)
  const [numPublished, setNumPublished] = useState(numPublishedSolutions)
  const [numCommentsEnabled, setNumCommentsEnabled] = useState(
    numSolutionsWithCommentsEnabled
  )
  const [commentStatusPhrase, setCommentStatusPhrase] = useState('')
  const [mutationsStatus, setMutationsStatus] =
    useState<ExtendedQueryStatus>('idle')
  const [mutationsError, setMutationsError] = useState<unknown>(null)

  const [successId, setSuccessId] = useState(0)

  const { mutation } = useSettingsMutation({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user_preferences: {
        allow_comments_on_published_solutions: allowCommentsByDefault,
      },
    },
    onSuccess: () => {
      setMutationsStatus('success')
      setSuccessId((s) => s + 1)
    },
    onError: (e) => {
      setMutationsError(e)
    },
  })

  function useCommentMutation(endpoint: string) {
    const { mutation } = useSettingsMutation({
      endpoint,
      method: 'PATCH',
      body: {},
      onSuccess: (d: {
        numPublishedSolutions: number
        numSolutionsWithCommentsEnabled: number
      }) => {
        setNumPublished(d.numPublishedSolutions)
        setNumCommentsEnabled(d.numSolutionsWithCommentsEnabled)
        setMutationsStatus('success')
        setSuccessId((s) => s + 1)
      },
      onError: (e) => {
        setMutationsError(e)
      },
    })

    return { mutation }
  }
  const { mutation: enableAllMutation } = useCommentMutation(
    links.enableCommentsOnAllSolutions
  )

  const { mutation: disableAllMutation } = useCommentMutation(
    links.disableCommentsOnAllSolutions
  )

  useEffect(() => {
    setCommentStatusPhrase(
      numCommentsEnabled === 0
        ? 'none'
        : numCommentsEnabled === numPublished
        ? 'all'
        : `${numCommentsEnabled} / ${numPublished}`
    )
  }, [numPublished, numCommentsEnabled])

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const handleCommentsPreferenceChange = useCallback((e) => {
    setAllowCommentsByDefault(e.target.checked)
  }, [])

  return {
    handleSubmit,
    handleCommentsPreferenceChange,
    enableAllMutation,
    disableAllMutation,
    commentStatusPhrase,
    mutationsError,
    mutationsStatus,
    successId,
    allowCommentsByDefault,
    numPublished,
    numCommentsEnabled,
  }
}
