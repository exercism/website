/**
 * Relative constant number the absolute number maps to
 */
export const RELATIVE_SIZE = 100

/**
 *
 * Convert relative x or y value to absolute value
 */
export function rToA(n: number) {
  return `${(n / RELATIVE_SIZE) * 100}%`
}

/**
 *
 * Convert absolute x or y value to absolute value
 */
export function aToR(n: number) {
  console.group('HERE')
  //return Math.round(n / (CANVAS_SIZE / RELATIVE_SIZE));
}
/**
 *
 */
export function relativeToAbsolute(x: number, y: number) {
  return { x: rToA(x), y: rToA(y) }
}
/**
 *
 */
export function absoluteToRelative(x: number, y: number) {
  return { x: aToR(x), y: aToR(y) }
}

// export function showMouseCoord(p: p5) {
//   const mouseX = p.mouseX;
//   const mouseY = p.mouseY;

//   let textX = mouseX + 10;
//   let textY = mouseY + 10;

//   const textWidth = p.textWidth(`(${mouseX}, ${mouseY})`);
//   const textHeight = 16;

//   // in case of overflow
//   if (textX + textWidth > p.width) {
//     textX = mouseX - textWidth - 10;
//   }

//   if (textY + textHeight > p.height) {
//     textY = mouseY - textHeight - 10;
//   }

//   if (textX < 0) {
//     textX = 10;
//   }

//   if (textY < 0) {
//     textY = 10;
//   }

//   const { x, y } = absoluteToRelative(mouseX, mouseY);
//   p.text(`(${x}, ${y})`, textX, textY);

//   p.stroke(0, 0, 0, 50);
//   // xline
//   p.line(mouseX, 0, mouseX, p.height);
//   // yline
//   p.line(0, mouseY, p.width, mouseY);
// }

// export function isMouseOverTheCanvas(p: p5) {
//   return p.mouseX >= 0 && p.mouseX <= p.width && p.mouseY >= 0 && p.mouseY <= p.height;
// }

/**
 * Converts the code string to a array of dictionary of function names and their arguments
 */
function parseCode(code: string): Array<{ [key: string]: number[] }> {
  const result: Array<{ [key: string]: number[] }> = []

  const lines = code.trim().split('\n')

  const regex = /(\w+)\(([\d\s,]+)\)/

  for (const line of lines) {
    const match = line.match(regex)
    if (match) {
      const functionName = match[1]
      const args = match[2].split(',').map((arg) => parseFloat(arg.trim()))
      const obj: { [key: string]: number[] } = {}
      obj[functionName] = args
      result.push(obj)
    }
  }

  return result
}

/**
 * Calls p5 function with arguments
 */
// export function drawThings(code: string, p: p5) {
//   const parsedCode = parseCode(code);
//   parsedCode.forEach((line) => {
//     const functionName = Object.keys(line)[0];
//     const args = line[functionName];
//     const digestedArgs = mapRelativeArgsToAbsoluteArgs(functionName, args);
//     // @ts-ignore
//     p[functionName](...digestedArgs);
//   });
// }

function mapRelativeArgsToAbsoluteArgs(functionName: string, args: number[]) {
  switch (functionName) {
    case 'rect':
      return args.map(rToA)
    default:
      return args
  }
}
