import React, { useCallback } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'

type StudentCodeGetter = () => string | undefined

function _Header({
  links,
  getStudentCode,
}: { getStudentCode: StudentCodeGetter } & Pick<DrawingPageProps, 'links'>) {
  const handleSaveDrawing = useCallback(
    async (getStudentCode: StudentCodeGetter) => {
      const studentCode = getStudentCode()

      const response = await fetch(links.updateCode, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          code: studentCode,
        }),
      })

      if (!response.ok) {
        throw new Error('Failed to save code')
      }

      return response.json()
    },
    [links.updateCode]
  )

  return (
    <div className="page-header">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>
      <div className="ml-auto flex items-center">
        <button
          onClick={() => handleSaveDrawing(getStudentCode)}
          className={assembleClassNames('btn-primary btn-xxs')}
        >
          Save
        </button>

        <a
          href={links.drawingsIndex}
          className={assembleClassNames('btn-secondary btn-xxs ml-8')}
        >
          Back
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
