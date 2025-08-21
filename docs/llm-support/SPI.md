# Service Provider Interface (SPI)

> **Related Documentation**: See [`API.md`](./API.md) for public API endpoints that complement these internal service routes.

The Service Provider Interface (`/spi`) provides internal endpoints for AWS Lambda functions, microservices, and Exercism infrastructure components. This document details the architecture, security model, and implementation patterns.

## Overview

SPI endpoints serve as the bridge between Exercism's main application and its distributed infrastructure:

- **AWS Lambda functions**: Post-processing results, tooling outcomes, and analysis data
- **Internal microservices**: Specialized services for code analysis, test running, and content processing
- **Infrastructure components**: Monitoring, logging, and operational tools
- **Background processors**: Asynchronous task results and status updates

## Security Model

### Infrastructure-Level Security
Unlike API endpoints, SPI routes are secured at the AWS infrastructure level rather than application-level authentication:

- **No application-level authentication required**: Endpoints trust that infrastructure controls access
- **AWS security groups**: Restrict network access to authorized Lambda functions and services
- **VPC isolation**: SPI endpoints only accessible within Exercism's private network
- **Service mesh authentication**: Mutual TLS and service identity verification at infrastructure layer

### Trust Model
SPI endpoints operate under a **trusted internal services** model:
- Services posting to SPI endpoints are assumed to be legitimate and authorized
- Data validation focuses on format and business logic, not authentication
- Audit logging tracks all SPI requests for security monitoring

## Route Architecture

### Endpoint Categories

#### Tooling Service Results
Handle results from automated code analysis and testing:

```ruby
namespace :spi do
  resources :tooling_jobs, only: :update do
    # PATCH /spi/tooling_jobs/:id
    # Updates job status and results from analysis tooling
  end
  
  resources :test_runs, only: [:create, :update] do
    # POST /spi/test_runs - Create new test run
    # PATCH /spi/test_runs/:id - Update with results
  end
end
```

#### AI Service Integration
Endpoints for ChatGPT and other AI service responses:

```ruby
namespace :spi do
  resources :chatgpt_responses, only: :create do
    # POST /spi/chatgpt_responses
    # Receives AI-generated feedback and explanations
  end
  
  resources :ai_analysis, only: :create do
    # POST /spi/ai_analysis
    # Machine learning insights and pattern detection
  end
end
```

#### Data Export and Analysis
Support for analytics and reporting services:

```ruby
namespace :spi do
  get "solution_image_data/:track_slug/:exercise_slug/:user_handle" => "solution_image_data#show"
  get "analytics/track_metrics/:track_slug" => "analytics#track_metrics"
  get "analytics/exercise_patterns/:exercise_slug" => "analytics#exercise_patterns"
end
```

#### Webhook Processors
Internal webhook handling for external service integration:

```ruby
namespace :spi do
  post "webhooks/github" => "webhooks#github"
  post "webhooks/discourse" => "webhooks#discourse"
  post "webhooks/payment_processor" => "webhooks#payment_processor"
end
```

## Implementation Patterns

### Controller Structure
SPI controllers focus on data validation and command delegation:

```ruby
class SPI::ToolingJobsController < SPI::BaseController
  def update
    tooling_job = ToolingJob.find(params[:id])
    
    cmd = ToolingJob::Complete.(tooling_job, spi_params)
    cmd.on_success { head :ok }
    cmd.on_failure { |errors| render_422(errors) }
  end

  private

  def spi_params
    params.require(:tooling_job).permit(:status, :output, :metadata)
  end
end
```

### Data Validation
SPI endpoints validate data format and business rules:

```ruby
class SPI::BaseController < ApplicationController
  # Skip authentication for SPI endpoints
  skip_before_action :authenticate_user!
  
  # Standard SPI error responses
  def render_422(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end
  
  def render_400(message)
    render json: { error: message }, status: :bad_request
  end
end
```

### Async Processing Integration
Many SPI endpoints trigger further background processing:

```ruby
class SPI::TestRunsController < SPI::BaseController
  def create
    cmd = TestRun::Create.(spi_params)
    
    cmd.on_success do |test_run|
      TestRun::ProcessResultsJob.perform_later(test_run)
      render json: { id: test_run.id }, status: :created
    end
    
    cmd.on_failure { |errors| render_422(errors) }
  end
end
```

## Lambda Function Integration

### Common Lambda Patterns

#### Result Posting
Lambda functions commonly post processing results:

```python
import requests

def lambda_handler(event, context):
    # Process code/data
    result = process_submission(event['submission_data'])
    
    # Post results back via SPI
    response = requests.patch(
        f"{SPI_BASE_URL}/tooling_jobs/{event['job_id']}",
        json={
            'tooling_job': {
                'status': 'completed',
                'output': result['output'],
                'metadata': result['metadata']
            }
        }
    )
    
    return {'statusCode': 200}
```

#### Error Handling
Lambda functions should handle SPI communication errors:

```python
def post_to_spi(endpoint, data, retries=3):
    for attempt in range(retries):
        try:
            response = requests.post(f"{SPI_BASE_URL}{endpoint}", json=data)
            if response.status_code < 300:
                return response
        except Exception as e:
            if attempt == retries - 1:
                # Log failure and potentially trigger alerts
                logger.error(f"Failed to post to SPI after {retries} attempts: {e}")
                raise
            time.sleep(2 ** attempt)  # Exponential backoff
```

## Data Flow Patterns

### Asynchronous Processing Flow
1. **User action** triggers job creation in main application
2. **Background job** sends work to Lambda via SQS/EventBridge
3. **Lambda function** processes data and posts results via SPI
4. **SPI endpoint** updates job status and triggers any follow-up processing
5. **WebSocket notification** informs user of completion

### Real-time Data Synchronization
Some SPI endpoints support real-time updates:

```ruby
class SPI::LiveDataController < SPI::BaseController
  def update_metrics
    cmd = Metrics::Update.(spi_params)
    
    cmd.on_success do |metrics|
      # Broadcast to connected clients
      ActionCable.server.broadcast(
        "metrics_#{params[:track_id]}", 
        metrics.to_json
      )
      head :ok
    end
  end
end
```

## Testing Patterns

### SPI Controller Tests
Focus on data validation and command integration:

```ruby
class SPI::ToolingJobsControllerTest < ActionDispatch::IntegrationTest
  test "updates tooling job with valid data" do
    tooling_job = create :tooling_job, status: :pending
    
    patch spi_tooling_job_path(tooling_job),
          params: {
            tooling_job: {
              status: 'completed',
              output: 'Analysis complete',
              metadata: { lines_analyzed: 150 }
            }
          },
          as: :json
    
    assert_response :ok
    assert_equal 'completed', tooling_job.reload.status
  end
  
  test "returns 422 for invalid data" do
    tooling_job = create :tooling_job
    
    patch spi_tooling_job_path(tooling_job),
          params: { tooling_job: { status: 'invalid_status' } },
          as: :json
    
    assert_response :unprocessable_entity
  end
end
```

### Lambda Integration Tests
Mock Lambda responses in tests:

```ruby
class ToolingJobProcessingTest < ActiveSupport::TestCase
  test "processes lambda results via SPI" do
    tooling_job = create :tooling_job, status: :pending
    
    # Simulate Lambda posting results
    post spi_tooling_job_path(tooling_job),
         params: {
           tooling_job: {
             status: 'completed',
             output: 'Test passed',
             metadata: { duration: 1500 }
           }
         },
         as: :json
    
    assert_equal 'completed', tooling_job.reload.status
    assert_equal 'Test passed', tooling_job.output
  end
end
```

## Monitoring and Observability

### Request Logging
All SPI requests are logged for audit and debugging:

```ruby
class SPI::BaseController < ApplicationController
  before_action :log_spi_request
  
  private
  
  def log_spi_request
    Rails.logger.info(
      "SPI Request: #{request.method} #{request.path} " \
      "from #{request.remote_ip} " \
      "params: #{params.except(:controller, :action)}"
    )
  end
end
```

### Metrics Collection
Track SPI endpoint usage and performance:

```ruby
class SPI::MetricsMiddleware
  def call(env)
    start_time = Time.current
    status, headers, response = @app.call(env)
    duration = Time.current - start_time
    
    StatsD.increment('spi.requests.total', tags: {
      endpoint: env['PATH_INFO'],
      status: status
    })
    
    StatsD.histogram('spi.requests.duration', duration, tags: {
      endpoint: env['PATH_INFO']
    })
    
    [status, headers, response]
  end
end
```

### Error Tracking
Monitor SPI failures for infrastructure issues:

```ruby
class SPI::BaseController < ApplicationController
  rescue_from StandardError do |exception|
    ExceptionNotifier.notify_exception(exception, 
      data: { 
        spi_endpoint: request.path,
        spi_params: params,
        remote_ip: request.remote_ip
      }
    )
    
    render_500("Internal server error")
  end
end
```

## Security Considerations

### Input Validation
Even with infrastructure-level security, validate all inputs:

```ruby
def spi_params
  params.require(:tooling_job).permit(:status, :output, metadata: {})
    .tap do |permitted|
      # Additional validation
      raise ArgumentError, "Invalid status" unless valid_status?(permitted[:status])
      raise ArgumentError, "Output too large" if permitted[:output]&.length > MAX_OUTPUT_SIZE
    end
end
```

### Rate Limiting
Implement basic rate limiting to prevent abuse:

```ruby
class SPI::BaseController < ApplicationController
  before_action :check_rate_limit
  
  private
  
  def check_rate_limit
    key = "spi_rate_limit:#{request.remote_ip}"
    requests = Redis.current.incr(key)
    Redis.current.expire(key, 60) if requests == 1
    
    if requests > SPI_RATE_LIMIT
      render_429("Rate limit exceeded")
    end
  end
end
```

### Data Sanitization
Sanitize all data before processing:

```ruby
def sanitize_output(output)
  # Remove potential secrets or sensitive data
  output.gsub(/password[=:]\s*\S+/i, 'password=***')
        .gsub(/token[=:]\s*\S+/i, 'token=***')
        .gsub(/key[=:]\s*\S+/i, 'key=***')
end
```