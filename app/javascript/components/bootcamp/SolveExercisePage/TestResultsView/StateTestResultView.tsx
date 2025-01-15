import { GraphicalIcon } from '@/components/common'
import React from 'react'
export function StateTestResultView({
  errorHtml,
}: {
  errorHtml: string | undefined
}) {
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
