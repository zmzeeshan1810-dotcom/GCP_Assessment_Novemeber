# High Availability & High-Volume Traffic Architecture Strategy

## 1. Executive Summary
This document defines the high availability (HA), autoscaling, resilience, and high-volume traffic management strategy for the Spring Boot HTTP microservice deployed on Google Cloud Run via Terraform. 

The architecture guarantees 99.95% uptime SLA by leveraging GCP native serverless autoscaling, multi-region routing, container-level health probes, and connection pooling.

---

## 2. Cloud Run Compute & Autoscaling Strategy

### 2.1 Capacity Planning & Scaling Parameters
Cloud Run handles horizontal instance scaling automatically based on incoming concurrency and CPU utilization.

| Parameter | Dev Value | Prod Value | Rationale |
| :--- | :--- | :--- | :--- |
| **`min_instances`** | `0` | `2` | Prevents cold starts in production while saving costs in dev. |
| **`max_instances`** | `3` | `50` | Protects downstream dependencies (databases) from exhaustion during traffic spikes. |
| **`container_concurrency`** | `80` | `80` | Aligns with Spring Boot’s embedded Tomcat thread model. |
| **`cpu`** | `1000m` | `2000m` | Grants 2 vCPUs in production to handle JVM garbage collection without throttling. |
| **`memory`** | `512Mi` | `1024Mi` | Allocates sufficient Heap for Java 21 runtime footprint. |
| **`cpu_idle`** | `true` | `false` (CPU Always Allocated) | Guarantees background threads and metrics reporting run continuously in prod. |

### 2.2 Cold Start Mitigation
To eliminate JVM cold-start latency (JIT compilation overhead during initial boot):
1. **Provisioned Instances**: Setting `min_instances = 2` ensures warm container instances are always standing by to serve instantaneous requests.
2. **Optimized JRE**: Using `eclipse-temurin:21-jre-alpine` reduces image layer size to under 180MB, minimizing container pull and launch times.

---

## 3. Health Monitoring & Traffic Routing

### 3.1 Probes & Endpoint Integration
Cloud Run uses native HTTP startup, liveness, and readiness probes tied to the Spring Boot REST endpoints:

```hcl
# Configured in terraform/modules/cloudrun/main.tf
liveness_probe {
  http_get {
    path = "/health"
    port = 8080
  }
  initial_delay_seconds = 10
  period_seconds        = 15
  failure_threshold     = 3
}

startup_probe {
  http_get {
    path = "/ready"
    port = 8080
  }
  initial_delay_seconds = 5
  period_seconds        = 5
  failure_threshold     = 10
}

/ready (Startup Probe): Ensures JVM initialization and Spring context loading are complete before Cloud Run routes live traffic to the instance.

/health (Liveness Probe): Periodically checks instance health; non-200 responses trigger automatic container termination and replacement.

4. Multi-Region Failover & Edge Security
For global high availability and DDoS mitigation, the Cloud Run instance sits behind a Global External Application Load Balancer (HTTPS ALB):
[ Global HTTP(S) Load Balancer / Cloud Armor WAF ]
                                     |
           +-------------------------+-------------------------+
           |                                                   |
           v                                                   v
[ Primary Region: us-central1 ]                     [ Secondary Region: us-east4 ]
   Cloud Run (Min: 2, Max: 50)                         Cloud Run (Min: 2, Max: 50)


Cloud Armor Security (WAF): Filters rate-limiting attacks, SQL injection, and OWASP Top 10 vulnerabilities at the Google Edge before traffic hits Cloud Run.

Anycast IP & Latency Routing: Routes users to the geographically nearest healthy region automatically.

Multi-Region Failover: If us-central1 suffers a regional GCP disruption, traffic shifts seamlessly to us-east4 within seconds.

5. Downstream System Protection (Database & API Limits)
High-volume traffic spikes on Cloud Run can easily overwhelm relational databases (Cloud SQL). To prevent database connection starvation:

Connection Pooling (HikariCP): Max pool size tuned to 10 connections per container instance (max_instances * 10 = 500 max DB connections).

Cloud SQL Auth Proxy / Serverless VPC Access: Cloud Run connects to Cloud SQL via a Serverless VPC Access Connector with private IPs, avoiding public internet exposure.

Resilience4j Circuit Breakers: Implemented in Spring Boot to fail fast when downstream microservices degrade, protecting system capacity.

---

Save `docs/ha-strategy.md` and commit both documentation files:

```powershell
git add docs/ha-strategy.md docs/incident-response.md
git commit -m "docs: finalize HA strategy and incident response documentation"
git push origin oidc-test

