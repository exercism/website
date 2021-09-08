import React, { useCallback, useRef } from 'react'
import ReactCrop from 'react-image-crop'
import { State, Action } from '../use-image-crop'
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

    /* The lib breaks if x or y are 0 */
    if (state.cropSettings.y == 0) {
      state.cropSettings.y = 1
    }
    if (state.cropSettings.x == 0) {
      state.cropSettings.x = 1
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
    <>
      <h3>Crop your photo</h3>
      <ReactCrop
        src={state.imageToCrop}
        crop={state.cropSettings}
        circularCrop={true}
        onChange={handleCropChange}
        onImageLoaded={handleImageLoaded}
        className="cropper"
        imageStyle={{ height: '50vh' }}
        keepSelection={true}
      />
      <div className="btns">
        <button
          type="button"
          onClick={handleCropCancel}
          className="btn-default btn-s"
        >
          Cancel
        </button>
        <button
          type="button"
          onClick={handleCropFinish}
          className="btn-primary btn-s"
        >
          Crop
        </button>
      </div>
    </>
  )
}
