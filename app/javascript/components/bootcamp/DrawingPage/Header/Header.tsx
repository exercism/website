import React, { useCallback, useState } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'

export type StudentCodeGetter = () => string | undefined

function _Header({
  links,
  savingStateLabel,
  drawing,
}: { savingStateLabel: string } & Pick<DrawingPageProps, 'links' | 'drawing'>) {
  const [titleInputValue, setTitleInputValue] = useState(drawing.title)
  const [editMode, setEditMode] = useState(false)
  const [titleSavingStateLabel, setTitleSavingStateLabel] =
    useState<string>('Save')

  const handleSaveTitle = useCallback(() => {
    setTitleSavingStateLabel('Saving...')
    patchDrawingTitle(links, titleInputValue)
      .then(() => {
        setTitleSavingStateLabel('Save')
        setEditMode(false)
      })
      .catch(() => setTitleSavingStateLabel('Failed to save'))
  }, [links, titleInputValue])

  return (
    <div className="page-header">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>
      <div className="ml-auto flex items-center gap-12">
        {savingStateLabel && (
          <span className="text-xs text-gray-500 font-semibold mr-4">
            {savingStateLabel}
          </span>
        )}
        <div className="flex items-center gap-12">
          {editMode ? (
            <>
              <button onClick={handleSaveTitle} className="btn-primary btn-xxs">
                {titleSavingStateLabel}
              </button>
              <button
                className="btn-secondary btn-xxs"
                onClick={() => setEditMode(false)}
              >
                Cancel
              </button>
              <input
                value={titleInputValue}
                onChange={(e) => {
                  setTitleInputValue(e.target.value)
                  setTitleSavingStateLabel('Save title')
                }}
                type="text"
                style={{ all: 'unset', borderBottom: '1px solid' }}
              />
            </>
          ) : (
            <>
              <button onClick={() => setEditMode(true)}>
                <GraphicalIcon icon="edit" height={15} width={15} />
              </button>
              <span>{titleInputValue}</span>
            </>
          )}
        </div>

        <a
          href={links.drawingsIndex}
          className={assembleClassNames('btn-secondary btn-xxs')}
        >
          Back to drawings
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)

async function patchDrawingTitle(
  links: DrawingPageProps['links'],
  title: string
) {
  const response = await fetch(links.updateCode, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      title,
    }),
  })

  if (!response.ok) {
    throw new Error('Failed to save code')
  }

  return response.json()
}
