# Secure Programmable Interface (SPI)

> **Related Documentation**: See [`API.md`](./API.md) for public API endpoints and [`commands.md`](./commands.md) for the command pattern used in SPI controllers.

The Secure Programmable Interface (`/spi`) provides internal endpoints for AWS Lambda functions, microservices, and Exercism infrastructure components. This document details the architecture, security model, and implementation patterns.

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

## Implementation

Like API endpoints, SPI controllers delegate business logic to Mandate commands (see [`commands.md`](./commands.md) for detailed patterns). This ensures consistent error handling and separation of concerns even for internal service endpoints.
