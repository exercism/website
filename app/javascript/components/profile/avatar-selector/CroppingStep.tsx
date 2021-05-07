import React, { useCallback, useRef } from 'react'
import ReactCrop from 'react-image-crop'
import { State, Action } from './reducer'
import { cropImage } from './cropImage'

export const CroppingStep = ({
  state,
  dispatch,
}: {
  state: State
  dispatch: React.Dispatch<Action>
}): JSX.Element => {
  if (!state.imageToCrop) {
    throw new Error('Cropped image was expected to exist')
  }

  const imageToCropRef = useRef<HTMLImageElement | null>(null)

  const handleCropChange = useCallback(
    (cropSettings) => {
      dispatch({
        type: 'crop.changed',
        payload: { cropSettings: cropSettings },
      })
    },
    [dispatch]
  )

  const handleImageLoaded = useCallback((image) => {
    imageToCropRef.current = image
  }, [])

  const handleCropFinish = useCallback(() => {
    if (!imageToCropRef.current) {
      return
    }

    cropImage(imageToCropRef.current, state.cropSettings).then((blob) => {
      if (!blob) {
        throw new Error('Unable to crop image')
      }

      dispatch({ type: 'crop.finished', payload: { croppedImage: blob } })
    })
  }, [dispatch, state.cropSettings])

  const handleCropCancel = useCallback(() => {
    dispatch({ type: 'crop.cancelled' })
  }, [dispatch])

  return (
    <div>
      <ReactCrop
        src={state.imageToCrop}
        crop={state.cropSettings}
        onChange={handleCropChange}
        onImageLoaded={handleImageLoaded}
      />
      <button type="button" onClick={handleCropCancel}>
        Cancel
      </button>
      <button type="button" onClick={handleCropFinish}>
        Finish
      </button>
    </div>
  )
}
