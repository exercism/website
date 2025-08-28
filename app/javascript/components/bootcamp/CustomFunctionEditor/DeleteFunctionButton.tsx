import React, { useCallback, useContext } from 'react'
import toast from 'react-hot-toast'
import { redirectTo } from '@/utils/redirect-to'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'

export function DeleteFunctionButton({ predefined }: { predefined: boolean }) {
  const { links } = useContext(JikiscriptExercisePageContext)

  const handleDeleteCustomFunction = useCallback(() => {
    const url = links.updateCustomFns as string
    const customFnDashboardUrl = links.customFnsDashboard as string

    if (window.confirm('Are you sure you want to delete this function?')) {
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
    }
  }, [links])

  if (predefined) {
    return null
  }

  return (
    <button onClick={handleDeleteCustomFunction} className="btn-alert btn-xxs">
      Delete
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
