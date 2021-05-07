export function cropImage(
  image: HTMLImageElement,
  crop: ReactCrop.Crop
): Promise<Blob | null> {
  if (!crop.width || !crop.height || !crop.x || !crop.y) {
    return Promise.resolve(null)
  }

  const scaleX = image.naturalWidth / image.width
  const scaleY = image.naturalHeight / image.height

  const canvas = document.createElement('canvas')
  canvas.width = crop.width
  canvas.height = crop.height

  const ctx = canvas.getContext('2d')
  if (!ctx) {
    throw new Error('Canvas context not found')
  }

  ctx.drawImage(
    image,
    crop.x * scaleX,
    crop.y * scaleY,
    crop.width * scaleX,
    crop.height * scaleY,
    0,
    0,
    crop.width,
    crop.height
  )

  const reader = new FileReader()

  return new Promise((resolve) => {
    canvas.toBlob((blob) => resolve(blob))
  })
}
