import React, { useCallback, useContext } from 'react'
import { SolveExercisePageContext } from '../SolveExercisePage/SolveExercisePageContextWrapper'
import { redirectTo } from '@/utils/redirect-to'
import toast from 'react-hot-toast'
export function DeleteFunctionButton() {
  const { links } = useContext(SolveExercisePageContext)

  const handleDeleteCustomFunction = useCallback(() => {
    const url = links.deleteCustomFn as string
    const customFnDashboardUrl = links.customFnsDashboard as string

    deleteCustomFunction(url)
      .then(() => {
        toast.success(
          'Deleted custom function successfully. Redirecting you to the dashboard..'
        )
        setTimeout(() => redirectTo(customFnDashboardUrl), 1000)
      })
      .catch((e) => {
        toast.error("Couldn't delete custom function. Please try it again.")
      })
  }, [links])

  return (
    <button
      onClick={handleDeleteCustomFunction}
      className="btn-alert btn-s justify-self-end mt-24"
    >
      Delete library function
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
