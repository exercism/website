import { ChartArea, ScriptableContext } from 'chart.js'

const BACKGROUND_GRADIENT_B = '#604FCD' // blueish
const FIGMA_BACKGROUND_GRADIENT_A = '#7029c8' //'rgb(112, 41, 200)' // purpleish - this is color-picked from figma design

export const FILL_COLOR = function (
  context: ScriptableContext<'line'>
): CanvasGradient | undefined {
  const chart = context.chart
  const { ctx, chartArea } = chart

  if (!chartArea) {
    // This case happens on initial chart load
    return
  }
  return getGradient(ctx, chartArea)
}

function getGradient(ctx: CanvasRenderingContext2D, chartArea: ChartArea) {
  let width, height, gradient
  const chartWidth = chartArea.right - chartArea.left
  const chartHeight = chartArea.bottom - chartArea.top
  if (!gradient || width !== chartWidth || height !== chartHeight) {
    // Create the gradient because this is either the first render
    // or the size of the chart has changed
    width = chartWidth
    height = chartHeight
    gradient = ctx.createLinearGradient(
      0,
      chartArea.bottom,
      0,
      chartArea.top + chartArea.bottom / 3
    ) // xStart, yStart, xEnd, yEnd
    gradient.addColorStop(0, FIGMA_BACKGROUND_GRADIENT_A)
    gradient.addColorStop(1, BACKGROUND_GRADIENT_B)
  }

  return gradient
}
