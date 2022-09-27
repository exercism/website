import React from 'react'
import { UploadVideoTextInput } from '.'
import { Icon } from '../../../common'
import RadioButton from '../../../mentoring/representation/right-pane/RadioButton'

export function UploadVideoControl(): JSX.Element {
  return (
    <div>
      {/* btn-i-filled has a different shadow than in Figma */}
      <button className="btn-m btn-default shadow-xsZ1v2 border-borderLight2 text-textColor6 mb-16">
        <Icon icon="reset" alt="Reset" className="!ml-0" />
        Use different video
      </button>

      <UploadVideoTextInput label="Video title" className="mb-24" />

      <fieldset className="flex flex-row font-body mb-32">
        <legend className="text-label text-btnBorder mb-16">
          IS THE VIDEO YOURS OR SOMEONE ELSES?
        </legend>
        <RadioButton
          name="who-owns-video"
          label="Mine"
          checked
          onChange={() => 'yolo'}
          value="mine"
        />
        <RadioButton
          name="who-owns-video"
          label="Someone else"
          checked
          onChange={() => 'yolo'}
          value="mine"
        />
      </fieldset>

      <div className="mb-24 text-p-base leading-150">
        Please ensure you have full rights to take credit for the video before
        submitting.
      </div>
      <div className="flex">
        <button className="w-full btn-primary btn-l grow">Submit video</button>
      </div>
    </div>
  )
}
