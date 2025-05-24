// import { toCanvas, toSvg } from '../../../../../../../html-to-image/src'
import { toCanvas, toSvg } from '@exercism/html-to-image'

export async function getIframePixels(
  iframeRef: React.RefObject<HTMLIFrameElement>
): Promise<Uint8ClampedArray | null> {
  const iframe = iframeRef.current
  if (!iframe) {
    return null
  }

  let pixels: Uint8ClampedArray | null = null

  const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document
  if (!iframeDoc || !iframeDoc.body) {
    return null
  }

  try {
    const encodedSvg = await toSvg(iframeDoc.body, {
      width: iframe.clientWidth,
      height: iframe.clientHeight,
    })
    // Random ID
    const svgId = `jiki-svg-${Math.random().toString(36).substring(2, 15)}`

    // Wrap everything
    const style = iframeDoc.createElement('style')
    style.innerHTML = `#${svgId} {`
    // Iterate through stylesheets
    for (const stylesheet of iframeDoc.styleSheets)
      for (const rule of stylesheet.cssRules) {
        // Add the rule to the style
        style.innerText += rule.cssText.replaceAll('\n', '')
      }
    style.innerHTML += `}`

    // Parse decoded into an SVG element
    let decoded = decodeURIComponent(encodedSvg.split(',')[1])
    const decodedElem = document.createElement('div')
    decodedElem.innerHTML = decoded
    const svg = decodedElem.firstChild! as SVGElement
    svg.id = svgId
    // document.body.appendChild(svg)

    const foreignObject = svg.firstChild! as SVGForeignObjectElement

    const bodyWrapper = document.createElement('div')
    bodyWrapper.classList.add('--jiki-faux-body')

    // Move all children inside the foreignObject to the wrappedDecoded
    for (const child of Array.from(foreignObject.children)) {
      bodyWrapper.appendChild(child)
    }
    bodyWrapper.appendChild(style)
    foreignObject.appendChild(bodyWrapper)

    // TODO: toCanvas expects an html element, but we have an SVG element - maybe do something about it?
    // @ts-expect-error
    const canvas = await toCanvas(svg, {
      width: iframe.clientWidth,
      height: iframe.clientHeight,
    })

    // uncomment to generate a download link for the actual canvas content

    // toJpeg(iframeDoc.body, { quality: 1 }).then(function (dataUrl) {
    //   var link = document.createElement('a')
    //   // Generate random name
    //   link.download = `iframe-${Math.random().toString(36).substring(2, 15)}.jpeg`
    //   link.href = dataUrl
    //   link.click()
    // })

    if (canvas) {
      const ctx = canvas.getContext('2d')
      if (ctx) {
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
        pixels = imageData.data
      }
    }

    return pixels
  } catch (err) {
    console.error('Failed to render iframe to canvas:', err)
    return null
  }
}
