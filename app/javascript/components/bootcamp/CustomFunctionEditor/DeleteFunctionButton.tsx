// i18n-key-prefix: deleteFunctionButton
// i18n-namespace: components/bootcamp/CustomFunctionEditor
import React, { useCallback, useContext } from 'react'
import toast from 'react-hot-toast'
import { redirectTo } from '@/utils/redirect-to'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function DeleteFunctionButton({ predefined }: { predefined: boolean }) {
  const { t } = useAppTranslation('components/bootcamp/CustomFunctionEditor')
  const { links } = useContext(JikiscriptExercisePageContext)

  const handleDeleteCustomFunction = useCallback(() => {
    const url = links.updateCustomFns as string
    const customFnDashboardUrl = links.customFnsDashboard as string

    if (
      window.confirm(
        t('deleteFunctionButton.areYouSureYouWantToDeleteThisFunction')
      )
    ) {
      deleteCustomFunction(url)
        .then(() => {
          toast.success(
            t(
              'deleteFunctionButton.deletedCustomFunctionSuccessfullyRedirectingYouToTheDashboard'
            )
          )
          setTimeout(() => redirectTo(customFnDashboardUrl), 1000)
        })
        .catch((e) => {
          toast.error(
            t(
              'deleteFunctionButton.couldntDeleteCustomFunctionPleaseTryItAgain'
            )
          )
        })
    }
  }, [links, t])

  if (predefined) {
    return null
  }

  return (
    <button onClick={handleDeleteCustomFunction} className="btn-alert btn-xxs">
      {t('deleteFunctionButton.delete')}
    </button>
  )
}

async function deleteCustomFunction(url: string): Promise<Response> {
  try {
    const response = await fetch(url, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
    })

    if (!response.ok) {
      throw new Error(`Error: ${response.status} ${response.statusText}`)
    }

    return response
  } catch (error) {
    console.error('DELETE request failed:', error)
    throw error
  }
}
