import {
  FunctionCallExpression,
  Expression,
  LiteralExpression,
} from '@/interpreter/expression'
import { Shape, Circle, Rectangle, Line } from './shapes'
import { InterpretResult } from '@/interpreter/interpreter'
import { extractFunctionCallExpressions } from '../../test-runner/generateAndRunTestSuite/checkers'

export function checkCanvasCoverage(shapes: Shape[], requiredPercentage) {
  const gridSize = 100
  const grid = Array.from({ length: gridSize }, () =>
    Array(gridSize).fill(false)
  )

  // Iterate through each circle
  shapes.forEach((shape) => {
    if (!(shape instanceof Circle)) {
      return
    }
    for (let x = 0; x < gridSize; x++) {
      for (let y = 0; y < gridSize; y++) {
        const distanceSquared = (x - shape.cx) ** 2 + (y - shape.cy) ** 2
        if (distanceSquared <= shape.radius ** 2) {
          grid[x][y] = true // Mark grid point as covered
        }
      }
    }
  })

  // Count covered points
  let coveredPoints = 0
  grid.forEach((row) => {
    coveredPoints += row.filter((point) => point).length
  })

  // Calculate coverage percentage
  const totalPoints = gridSize * gridSize
  const percentage = (coveredPoints / totalPoints) * 100

  return percentage >= requiredPercentage
}

export function checkUniqueColoredRectangles(shapes: Shape[], count: number) {
  let colors = new Set()
  shapes.forEach((shape) => {
    if (!(shape instanceof Rectangle)) {
      return
    }

    colors.add(`${shape.fillColor.type}-${shape.fillColor.color.toString()}`)
  })
  return colors.size >= count
}
export function checkUniqueColoredLines(shapes: Shape[], count: number) {
  let colors = new Set()
  shapes.forEach((shape) => {
    if (!(shape instanceof Line)) {
      return
    }

    colors.add(`${shape.strokeColor.color.toString()}`)
  })
  return colors.size >= count
}

export function checkUniqueColoredCircles(shapes: Shape[], count: number) {
  let colors = new Set()
  shapes.forEach((shape) => {
    if (!(shape instanceof Circle)) {
      return
    }
    colors.add(
      `${
        shape.fillColor.type
      }-${shape.strokeColor.color.toString()}-${shape.fillColor.color.toString()}`
    )
  })
  return colors.size >= count
}

export function assertAllArgumentsAreVariables(
  interpreterResult: InterpretResult
) {
  return extractFunctionCallExpressions(
    interpreterResult.meta.statements
  ).every((expr: FunctionCallExpression) => {
    return expr.args.every((arg: Expression) => {
      return !(arg instanceof LiteralExpression)
    })
  })
}
