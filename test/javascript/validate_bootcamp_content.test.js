import { evaluateJikiScriptFunction } from '@/interpreter/interpreter'
import fs from 'fs'
import path from 'path'

const contentDir = path.resolve(__dirname, '../../bootcamp_content/projects')

function getSubdirectories(dir) {
  return fs
    .readdirSync(dir)
    .filter((file) => fs.statSync(path.join(dir, file)).isDirectory())
}

function getConfig(exerciseDir) {
  const configPath = path.join(exerciseDir, 'config.json')
  return JSON.parse(fs.readFileSync(configPath, 'utf-8'))
}

function getExampleScript(exerciseDir) {
  const examplePath = path.join(exerciseDir, 'example.jiki')
  return fs.readFileSync(examplePath, 'utf-8')
}

describe('Exercise Tests', () => {
  const projects = getSubdirectories(contentDir)

  projects.forEach((project) => {
    const projectDir = contentDir + '/' + project + '/exercises'
    const exercises = getSubdirectories(projectDir)
    exercises.forEach((exercise) => {
      const exerciseDir = path.join(projectDir, exercise)
      const config = getConfig(exerciseDir)
      const exampleScript = getExampleScript(exerciseDir)

      if (config.tests_type == 'state') {
        return
      }

      config.tasks.forEach((task) => {
        task.tests.forEach((taskTest) => {
          test(`${project} - ${exercise} - ${task.name} - ${taskTest.name}`, () => {
            let error, value, frames
            try {
              ;({ error, value, frames } = evaluateJikiScriptFunction(
                exampleScript,
                {},
                taskTest.function,
                ...taskTest.params
              ))
            } catch (e) {
              console.log(e)
              expect(true).toBe(false)
            }

            // if(value != taskTest.expected.return) {
            //   console.log(error, value, frames);
            // }
            expect(value).toEqual(taskTest.expected)
          })
        })
      })
    })
  })
})
