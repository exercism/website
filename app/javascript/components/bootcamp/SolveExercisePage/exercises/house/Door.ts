import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { storeShape, changeBrightness } from './Component'
import HouseExercise from './HouseExercise'

function fn(this: HouseExercise) {
  const drawDoor = (executionCtx: ExecutionContext, door: Jiki.Instance) => {
    this.fillColorHex(executionCtx, new Jiki.String('#A0512D'))
    this.rectangle(
      executionCtx,
      door.getField('left') as Jiki.Number,
      door.getField('top') as Jiki.Number,
      door.getField('width') as Jiki.Number,
      door.getField('height') as Jiki.Number
    )
    storeShape(this, door)

    this.fillColorHex(executionCtx, new Jiki.String('#FFDF00'))
    this.circle(
      executionCtx,
      //@ts-ignore
      new Jiki.Number(
        door.getUnwrappedField('left') + door.getUnwrappedField('width') - 2
      ),
      //@ts-ignore
      new Jiki.Number(
        door.getUnwrappedField('top') + door.getUnwrappedField('height') / 2
      ),
      new Jiki.Number(1)
    )
    const knobShape = this.shapes[this.shapes.length - 1]
    knobShape.element.style.filter = 'brightness(100%)'
    knobShape.element.style.zIndex = door
      .getUnwrappedField('z_index')
      .toString()
    door['knobShape'] = knobShape
  }

  const changeDoorBrightness = (
    executionCtx: ExecutionContext,
    door: Jiki.Instance
  ) => {
    const shape = door['knobShape']
    this.addAnimation({
      targets: `#${this.view.id} #${shape.element.id}`,
      duration: 1,
      transformations: {
        filter: `brightness(${door.getUnwrappedField('brightness')}%)`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    changeBrightness(executionCtx, this, door)
    this.events.push(`door:brightness:${door.getUnwrappedField('brightness')}`)
  }

  const Door = new Jiki.Class('Door')
  Door.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    left: Jiki.JikiObject,
    top: Jiki.JikiObject,
    width: Jiki.JikiObject,
    height: Jiki.JikiObject,
    z_index: Jiki.JikiObject
  ) {
    if (
      !(left instanceof Jiki.Number) ||
      !(top instanceof Jiki.Number) ||
      !(width instanceof Jiki.Number) ||
      !(height instanceof Jiki.Number) ||
      !(z_index instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All parameters must be numbers.')
    }
    object.setField('left', left)
    object.setField('top', top)
    object.setField('width', width)
    object.setField('height', height)
    object.setField('z_index', z_index)
    drawDoor(executionCtx, object)
  })
  Door.addSetter(
    'brightness',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      brightness: Jiki.JikiObject
    ) {
      if (!(brightness instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Brightness must be a number.')
      }
      if (brightness.value < 0 || brightness.value > 100) {
        executionCtx.logicError('Brightness must be between 0 and 100')
      }
      object.setField('brightness', brightness)
      changeDoorBrightness(executionCtx, object)
    }
  )
  return Door
}

export function buildDoor(binder: any) {
  return fn.bind(binder)()
}
