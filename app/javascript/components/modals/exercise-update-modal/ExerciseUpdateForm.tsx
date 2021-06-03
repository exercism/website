import React from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { ExerciseDiff } from '../ExerciseUpdateModal'
import { useIsMounted } from 'use-is-mounted'
import { GraphicalIcon, ExerciseIcon, FormButton } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { SolutionForStudent } from '../../types'
import { typecheck } from '../../../utils/typecheck'

const DEFAULT_ERROR = new Error('Unable to update exercise')

export const ExerciseUpdateForm = ({
  diff,
  onCancel,
}: {
  diff: ExerciseDiff
  onCancel: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()

  const [mutation, { status, error }] = useMutation<SolutionForStudent>(
    () => {
      return sendRequest({
        endpoint: diff.links.update,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        return typecheck<SolutionForStudent>(json, 'solution')
      })
    },
    {
      onSuccess: (solution) => {
        window.location.replace(solution.privateUrl)
      },
    }
  )

  return (
    <>
      <header className="header">
        <h2>
          See what's changed on
          <ExerciseIcon iconUrl={diff.exercise.iconUrl} />
          {diff.exercise.title}
        </h2>
      </header>
      <div className="tabs">
        {diff.files.map((file) => (
          <div className="c-tab selected">{file.filename}</div>
        ))}
      </div>

      {diff.files.map((file) => (
        <div className="c-diff">
          {/*https://github.com/rtfpessoa/diff2html*/}
          <SampleOutput />
        </div>
      ))}
      <div className="warning">
        By updating to the latest version, your solution may fail the tests and
        need to be updated.
      </div>
      <form>
        <FormButton
          type="button"
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          <GraphicalIcon icon="reset" />
          <span>Update exercise</span>
        </FormButton>
        <FormButton
          type="button"
          onClick={onCancel}
          status={status}
          className="dismiss-btn"
        >
          Dismiss
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </>
  )
}

const SampleOutput = ({}: {}): JSX.Element => {
  return (
    <div className="d2h-file-list-wrapper">
      <div className="d2h-file-diff">
        <div className="d2h-code-wrapper">
          <table className="d2h-diff-table">
            <tbody className="d2h-diff-tbody">
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">4</div>
                  <div className="line-num2">4</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      public class LasagnaTests
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">5</div>
                  <div className="line-num2">5</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"></span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">6</div>
                  <div className="line-num2">6</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> [Fact]</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-ins">
                  <div className="line-num1"></div>
                  <div className="line-num2">7</div>
                </td>
                <td className="d2h-ins">
                  <div className="d2h-code-line d2h-ins">
                    <span className="d2h-code-line-prefix">+</span>
                    <span className="d2h-code-line-ctn"> [Task(1)]</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">7</div>
                  <div className="line-num2">8</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      public void Expected_minutes_in_oven()
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">8</div>
                  <div className="line-num2">9</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">9</div>
                  <div className="line-num2">10</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      Assert.Equal(40, new Lasagna().ExpectedMinutesInOven());
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">10</div>
                  <div className="line-num2">11</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> }</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">11</div>
                  <div className="line-num2">12</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      <br />
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">12</div>
                  <div className="line-num2">13</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      [Fact(Skip = &#x27;Remove this Skip property to run this
                      test&#x27;)]
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-ins">
                  <div className="line-num1"></div>
                  <div className="line-num2">14</div>
                </td>
                <td className="d2h-ins">
                  <div className="d2h-code-line d2h-ins">
                    <span className="d2h-code-line-prefix">+</span>
                    <span className="d2h-code-line-ctn"> [Task(2)]</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">13</div>
                  <div className="line-num2">15</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      public void Remaining_minutes_in_oven()
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">14</div>
                  <div className="line-num2">16</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">15</div>
                  <div className="line-num2">17</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      Assert.Equal(15, new
                      Lasagna().RemainingMinutesInOven(25));
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">16</div>
                  <div className="line-num2">18</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> }</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">17</div>
                  <div className="line-num2">19</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      <br />
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">18</div>
                  <div className="line-num2">20</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      [Fact(Skip = &#x27;Remove this Skip property to run this
                      test&#x27;)]
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-ins">
                  <div className="line-num1"></div>
                  <div className="line-num2">21</div>
                </td>
                <td className="d2h-ins">
                  <div className="d2h-code-line d2h-ins">
                    <span className="d2h-code-line-prefix">+</span>
                    <span className="d2h-code-line-ctn"> [Task(3)]</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">19</div>
                  <div className="line-num2">22</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      public void Preparation_time_in_minutes_for_one_layer()
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">20</div>
                  <div className="line-num2">23</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">21</div>
                  <div className="line-num2">24</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      Assert.Equal(2, new
                      Lasagna().PreparationTimeInMinutes(1));
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">22</div>
                  <div className="line-num2">25</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> }</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">23</div>
                  <div className="line-num2">26</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      <br />
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">24</div>
                  <div className="line-num2">27</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      [Fact(Skip = &#x27;Remove this Skip property to run this
                      test&#x27;)]
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-ins">
                  <div className="line-num1"></div>
                  <div className="line-num2">28</div>
                </td>
                <td className="d2h-ins">
                  <div className="d2h-code-line d2h-ins">
                    <span className="d2h-code-line-prefix">+</span>
                    <span className="d2h-code-line-ctn"> [Task(3)]</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">25</div>
                  <div className="line-num2">29</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      public void
                      Preparation_time_in_minutes_for_multiple_layers()
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">26</div>
                  <div className="line-num2">30</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">27</div>
                  <div className="line-num2">31</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      Assert.Equal(8, new
                      Lasagna().PreparationTimeInMinutes(4));
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">28</div>
                  <div className="line-num2">32</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> }</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">29</div>
                  <div className="line-num2">33</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      <br />
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">30</div>
                  <div className="line-num2">34</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      [Fact(Skip = &#x27;Remove this Skip property to run this
                      test&#x27;)]
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-ins">
                  <div className="line-num1"></div>
                  <div className="line-num2">35</div>
                </td>
                <td className="d2h-ins">
                  <div className="d2h-code-line d2h-ins">
                    <span className="d2h-code-line-prefix">+</span>
                    <span className="d2h-code-line-ctn"> [Task(4)]</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">31</div>
                  <div className="line-num2">36</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      public void Elapsed_time_in_minutes_for_one_layer()
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">32</div>
                  <div className="line-num2">37</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">33</div>
                  <div className="line-num2">38</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      Assert.Equal(32, new Lasagna().ElapsedTimeInMinutes(1,
                      30));
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">34</div>
                  <div className="line-num2">39</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> }</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">35</div>
                  <div className="line-num2">40</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      <br />
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">36</div>
                  <div className="line-num2">41</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      [Fact(Skip = &#x27;Remove this Skip property to run this
                      test&#x27;)]
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-ins">
                  <div className="line-num1"></div>
                  <div className="line-num2">42</div>
                </td>
                <td className="d2h-ins">
                  <div className="d2h-code-line d2h-ins">
                    <span className="d2h-code-line-prefix">+</span>
                    <span className="d2h-code-line-ctn"> [Task(4)]</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">37</div>
                  <div className="line-num2">43</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      public void Elapsed_time_in_minutes_for_multiple_layers()
                    </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">38</div>
                  <div className="line-num2">44</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn"> </span>
                  </div>
                </td>
              </tr>
              <tr>
                <td className="d2h-code-linenumber d2h-cntx">
                  <div className="line-num1">39</div>
                  <div className="line-num2">45</div>
                </td>
                <td className="d2h-cntx">
                  <div className="d2h-code-line d2h-cntx">
                    <span className="d2h-code-line-prefix">&nbsp;</span>
                    <span className="d2h-code-line-ctn">
                      {' '}
                      Assert.Equal(16, new Lasagna().ElapsedTimeInMinutes(4,
                      8));
                    </span>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
