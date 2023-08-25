import React from 'react'
import { Icon, GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { FormMessage } from '../FormMessage'
import { useCommentsPreferenceForm } from './useCommentsPreferenceForm'
import { ManageExistingSolution } from './ManageExistingSolutions'

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

export default function CommentsPreferenceForm({
  currentPreference,
  links,
  label,
  numPublishedSolutions,
  numSolutionsWithCommentsEnabled,
}: CommentsPreferenceFormProps): JSX.Element {
  const {
    handleSubmit,
    commentStatusPhrase,
    disableAllMutation,
    enableAllMutation,
    mutationsError,
    mutationsStatus,
    successId,
    handleCommentsPreferenceChange,
    allowCommentsByDefault,
    numPublished,
    numCommentsEnabled,
  } = useCommentsPreferenceForm({
    currentPreference,
    links,
    numPublishedSolutions,
    numSolutionsWithCommentsEnabled,
  })

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
          <FormButton status={mutationsStatus} className="btn-primary btn-m">
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
      <ManageExistingSolution
        numPublished={numPublished}
        numCommentsEnabled={numCommentsEnabled}
        commentStatusPhrase={commentStatusPhrase}
        enableAllMutation={enableAllMutation}
        disableAllMutation={disableAllMutation}
      />
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
