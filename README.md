# AWS E-Commerce Infrastructure

A production-ready e-commerce infrastructure built on AWS using Terraform, featuring comprehensive monitoring and high availability.

## Architecture Overview

This infrastructure implements a modern microservices architecture deployed on Amazon EKS with:
- Multi-AZ deployment for high availability
- Containerized microservices
- Automated scaling
- Comprehensive monitoring
- Security best practices

## Key Components

### Infrastructure
- **VPC**: Multi-AZ setup with public/private subnets
- **EKS**: Managed Kubernetes cluster
- **RDS**: PostgreSQL database with read replicas
- **ElastiCache**: Redis for session management and caching
- **ALB**: Application Load Balancer with WAF integration

### Monitoring Stack
- **CloudWatch**: AWS native monitoring and logging
- **Prometheus**: Metrics collection and storage
- **Grafana**: Metrics visualization and dashboards
- **Fluent Bit**: Container log aggregation
- **Custom Alerts**: Business and technical metrics monitoring

### Security Features
- WAF protection
- Network segmentation
- IAM roles and policies
- SSL/TLS encryption
- Security groups

## Quick Start

1. **Prerequisites**
   ```bash
   - AWS CLI configured
   - Terraform >= 1.0.0
   - kubectl
   - helm
   ```

2. **Deploy Infrastructure**
   ```bash
   cd terraform/environments/dev
   terraform init
   terraform plan
   terraform apply
   ```

3. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --name <cluster-name> --region <region>
   ```

4. **Access Monitoring**
   - Grafana: http://grafana.<your-domain>
   - Prometheus: http://prometheus.<your-domain>

## Monitoring Features

- Real-time metrics visualization
- Business KPI dashboards
- Infrastructure monitoring
- Application performance metrics
- Automated alerting
- Log aggregation and analysis

## Directory Structure
```
├── terraform/
│   ├── modules/           # Reusable infrastructure components
│   └── environments/      # Environment-specific configurations
├── kubernetes/           # Kubernetes manifests
├── src/                 # Application source code
└── docs/               # Additional documentation
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the GitHub repository.