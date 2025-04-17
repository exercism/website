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

        {inspectedPreviewTaskTest.descriptionHtml &&
          inspectedPreviewTaskTest.descriptionHtml.length > 0 && (
            <div className="description text-bootcamp-purple">
              <strong>Task: </strong>
              <span
                dangerouslySetInnerHTML={{
                  __html: inspectedPreviewTaskTest.descriptionHtml ?? '',
                }}
              />
            </div>
          )}
      </div>
    </div>
  )
}
