import React from 'react'
export function StatePreview({
  inspectedPreviewTaskTest,
}: {
  inspectedPreviewTaskTest: TaskTest
}) {
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>Scenario: </strong>
          {inspectedPreviewTaskTest.name}
        </h3>
        <div
          className="text-bootcamp-purple font-medium content"
          dangerouslySetInnerHTML={{
            __html: inspectedPreviewTaskTest.descriptionHtml ?? '',
          }}
        />
      </div>
    </div>
  )
}
