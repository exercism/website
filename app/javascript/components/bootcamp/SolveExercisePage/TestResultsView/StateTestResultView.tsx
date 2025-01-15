import { GraphicalIcon } from '@/components/common'
import { useLogger } from '@/hooks'
import React from 'react'
export function StateTestResultView({
  errorHtml,
}: {
  errorHtml: string | undefined
}) {
  useLogger('errorHtml', errorHtml)
  if (!errorHtml) return null
  return (
    <div className="error-message">
      <GraphicalIcon icon="bootcamp-cross-red" />
      <div>
        <strong>Uh Oh.</strong>{' '}
        <span dangerouslySetInnerHTML={{ __html: errorHtml }} />
      </div>
    </div>
  )
}
