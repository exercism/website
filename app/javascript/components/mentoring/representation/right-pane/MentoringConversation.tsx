import React, { useCallback, useState } from 'react'
import { QueryStatus } from 'react-query'
import { MarkdownEditorForm } from '../../../common/MarkdownEditorForm'

export default function MentoringConversation(): JSX.Element {
  const [value, setValue] = useState('')

  const handleCancel = useCallback(() => console.log('Cancelled!'), [])
  const handleChange = useCallback((value) => setValue(value), [setValue])
  return (
    <div className="px-24">
      <MarkdownEditorForm
        value={value}
        onChange={handleChange}
        onCancel={handleCancel}
        expanded
        action="edit"
        defaultError={new Error('ERROR!')}
        error="Error"
        onSubmit={() => console.log('Submitted')}
        status={'success' as QueryStatus}
      />
      <div className="mt-12 mb-20 text-textColor6 bg-veryLightBlue py-4 px-8 rounded-5">
        We imported your last mentoring feedback to this solution above
      </div>
      <Button />
      <div className="text-textColor6">
        Remember, you can edit this feedback anytime after submission.
      </div>
    </div>
  )
}

function Button() {
  return (
    <button className="border-1 border-primaryBtnBorder shadow-xsZ1v3 mb-16 bg-purple text-white text-16 font-semibold px-[68px] py-[12px] rounded-8">
      Preview & Submit
    </button>
  )
}
