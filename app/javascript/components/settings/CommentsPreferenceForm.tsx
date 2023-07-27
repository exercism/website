import React, { useState, useCallback, useEffect } from 'react'
import { useSettingsMutation } from './useSettingsMutation'
import { FormButton, Icon, GraphicalIcon } from '../common'
import { FormMessage } from './FormMessage'
import { QueryStatus } from 'react-query'

type Links = Record<
  'update' | 'enableCommentsOnAllSolutions' | 'disableCommentsOnAllSolutions',
  string
>

export type CommentsPreferenceFormProps = {
  links: Links
  currentPreference: boolean
  label: string
  numPublishedSolutions: number
  numSolutionsWithCommentsEnabled: number
}

const DEFAULT_ERROR = new Error('Unable to change preferences')

export const CommentsPreferenceForm = ({
  currentPreference,
  links,
  label,
  numPublishedSolutions,
  numSolutionsWithCommentsEnabled,
}: CommentsPreferenceFormProps): JSX.Element => {
  const [allowCommentsByDefault, setAllowCommentsByDefault] =
    useState(currentPreference)
  const [numPublished, setNumPublished] = useState(numPublishedSolutions)
  const [numCommentsEnabled, setNumCommentsEnabled] = useState(
    numSolutionsWithCommentsEnabled
  )
  const [commentStatusPhrase, setCommentStatusPhrase] = useState('')
  const [mutationsStatus, setMutationsStatus] = useState<QueryStatus>(
    QueryStatus.Idle
  )
  const [mutationsError, setMutationsError] = useState<unknown>(null)

  const [successId, setSuccessId] = useState(0)

  const { mutation, status } = useSettingsMutation({
    endpoint: links.update,
    method: 'PATCH',
    body: {
      user_preferences: {
        allow_comments_on_published_solutions: allowCommentsByDefault,
      },
    },
    onSuccess: () => {
      setMutationsStatus(QueryStatus.Success)
      setSuccessId((s) => s + 1)
    },
    onError: (e) => {
      setMutationsError(e)
    },
  })

  function useCommentMutation(endpoint: string) {
    const { mutation, status, error } = useSettingsMutation({
      endpoint,
      method: 'PATCH',
      body: {},
      onSuccess: (d: {
        numPublishedSolutions: number
        numSolutionsWithCommentsEnabled: number
      }) => {
        setNumPublished(d.numPublishedSolutions)
        setNumCommentsEnabled(d.numSolutionsWithCommentsEnabled)
        setMutationsStatus(QueryStatus.Success)
        setSuccessId((s) => s + 1)
      },
      onError: (e) => {
        setMutationsError(e)
      },
    })

    return { mutation, status, error }
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

  return (
    <>
      <form data-turbo="false" onSubmit={handleSubmit}>
        <h2 className="!mb-8">Comments on your solutions</h2>
        <p className="text-p-base mb-12">
          Use this setting to control whether or not people can post comments on{' '}
          <span className="font-medium">future solutions that you publish</span>
          . This can be overriden on a per-solution basis and you can update all
          existing solutions below.
        </p>
        <label className="c-checkbox-wrapper">
          <input
            type="checkbox"
            checked={allowCommentsByDefault}
            onChange={handleCommentsPreferenceChange}
          />
          <div className="row">
            <div className="c-checkbox">
              <GraphicalIcon icon="checkmark" />
            </div>
            {label}
          </div>
        </label>

        <div className="form-footer !border-0 !pt-0 !mt-0">
          <FormButton status={status} className="btn-primary btn-m">
            Update preference
          </FormButton>
          <FormMessage
            key={successId}
            status={mutationsStatus}
            defaultError={DEFAULT_ERROR}
            error={mutationsError}
            SuccessMessage={SuccessMessage}
          />
        </div>
      </form>
      {numPublished > 0 ? (
        <div className="form-footer">
          <div className="flex flex-col items-start">
            <h3 className="text-h5 mb-4">Manage existing solutions</h3>
            <p className="text-p-base mb-12">
              Currently, people can comment on {commentStatusPhrase} of your
              published solutions. Use the buttons below to{' '}
              <span className="font-medium">
                enable or disable comments on all your existing solutions.
              </span>
              .
            </p>
            <div className="flex gap-12">
              <button
                onClick={() => enableAllMutation()}
                disabled={numCommentsEnabled === numPublished}
                className="btn-m btn-enhanced"
              >
                Allow comments on all existing solutions
              </button>

              <button
                onClick={() => disableAllMutation()}
                disabled={numCommentsEnabled === 0}
                className="btn-m btn-enhanced"
              >
                Disable comments on all existing solutions
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </>
  )
}

const SuccessMessage = () => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your preferences have been updated
    </div>
  )
}
