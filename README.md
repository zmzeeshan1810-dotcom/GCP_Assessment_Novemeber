# Java Spring Boot Service Delivery Pattern on GCP Cloud Run

## 1. Executive Summary
This repository presents a production-grade Infrastructure as Code (IaC) and Continuous Integration/Continuous Deployment (CI/CD) pattern for containerized Java microservices on Google Cloud Platform (GCP).

The implementation features:
* **Application Stack**: Java 21 Spring Boot REST microservice (`/health`, `/ready`, `/version`).
* **Containerization**: Multi-stage Docker build (`maven:3.9.9-eclipse-temurin-21` to `eclipse-temurin:21-jre-alpine`) executing under non-root security contexts (`USER spring`).
* **Infrastructure**: Reusable Terraform modules (`modules/cloudrun`) supporting dynamic environment isolation (`dev`, `prod`).
* **Keyless Security**: GCP Workload Identity Federation (OIDC) eliminating static service account keys in GitHub Actions.
* **Automated Quality Gates**: PR validation including Java unit tests, Terraform syntax/formatting (`terraform fmt`, `terraform validate`), contract testing (`terraform test`), and vulnerability scanning (`Trivy v0.20.0`).

---

## 2. Repository Structure

```text
.
├── .github/workflows/
│   ├── pr-validation.yml         # PR Pipeline: Build, HCL format, TF unit test, Trivy scan
│   └── deploy-main.yml           # CD Pipeline: OIDC Auth, Artifact Registry push, TF apply
├── docs/
│   ├── ha-strategy.md            # High Availability, Autoscaling, & Traffic Strategy
│   └── incident-response.md      # Emergency Rollbacks, State Locks, & Operational Runbook
├── terraform/
│   ├── main.tf                   # Root configuration calling Cloud Run child module
│   ├── variables.tf              # Input variable definitions
│   ├── outputs.tf                # Service URL & revision outputs
│   ├── modules/
│   │   └── cloudrun/             # Reusable Cloud Run child module
│   ├── tests/
│   │   └── cloudrun.tftest.hcl   # Native HCL contract assertions for Dev/Prod
│   └── environments/
│       ├── dev/                  # dev.tfvars & backend.tfbackend
│       └── prod/                 # prod.tfvars & backend.tfbackend
├── src/                          # Java Spring Boot source code
├── Dockerfile                    # Multi-stage security-hardened Dockerfile
├── pom.xml                       # Maven dependency management
└── README.md                     # Final Submission & Architecture Documentation

3. Local Execution & Validation Guide
You can run the full validation suite locally without requiring active GCP cloud access:

3.1 Validate Infrastructure (Terraform)
cd terraform

# 1. Initialize in offline mode
terraform init -backend=false

# 2. Validate HCL syntax
terraform validate

# 3. Check code formatting
terraform fmt -check

# 4. Run native unit contract tests
terraform test

3.2 Build & Test Java Container (Docker & Trivy)

# 1. Build local container image
docker build -t sample-service:local .

# 2. Test Spring Boot endpoint probes locally
docker run -d -p 8080:8080 --name app sample-service:local
curl http://localhost:8080/health
curl http://localhost:8080/ready
docker stop app && docker rm app

# 3. Scan container image for vulnerabilities
trivy image --severity HIGH,CRITICAL sample-service:local

4. Pipeline Architecture (CI/CD Flow)
[ Developer Branch ] 
       |
       +---> Push / PR Trigger ---> [ PR Validation Workflow ]
                                          |-- Maven Package & Tests
                                          |-- Terraform fmt & validate
                                          |-- Native `terraform test`
                                          |-- Trivy Container Vulnerability Scan
                                          v
[ Merge to Main ] -----------------> [ Deploy Main Workflow ]
                                          |-- OIDC Keyless GCP Authentication
                                          |-- Build & Push Image to Artifact Registry
                                          |-- Generate `tfplan` Artifact
                                          |-- Execute `terraform apply` (Dev / Prod)

Pull Request Validation (pr-validation.yml): Fires on PRs targeting main. Uses offline flags (-backend=false) to ensure validation runs fast, isolated, and credential-free.

Post-Merge Deployment (deploy-main.yml): Fires on commit merge to main. Requests short-lived JWT tokens from GCP via Keyless OIDC (google-github-actions/auth), pushes immutable images tagged with ${{ github.sha }}, and executes artifact-driven terraform apply.


5. Production Strategy Documentation
Detailed architectural and operational documentation is available in the docs/ directory:

High Availability Architecture (docs/ha-strategy.md): Details horizontal autoscaling (min_instances = 2, max_instances = 50), JVM warm-up probe configurations (/ready and /health), Cloud Armor WAF integration, and database connection pool tuning.

Incident Response Runbook (docs/incident-response.md): Outlines 5-second P1 revision rollbacks via gcloud run services update-traffic, GCS backend state lock recovery (terraform force-unlock), JVM Out-Of-Memory triage, and zero-downtime database cutovers.

6. Candidate Trade-Off Disclosures & Architectural Decisions
Native terraform test vs. Terratest:

Decision: Utilized native HCL .tftest.hcl introduced in Terraform 1.6+ instead of Go-based Terratest.

Trade-off: Reduces external Go binary dependencies and speeds up CI pipeline runtime while providing contract assertions.

Serverless Cloud Run vs. Kubernetes (GKE):

Decision: Selected Cloud Run for statutory stateless HTTP API delivery.

Trade-off: Eliminates control plane management overhead and cluster node autoscaling complexity, though custom Kubernetes CRDs/service meshes (Istio) are omitted.

Keyless OIDC vs. Service Account Keys:

Decision: Enforced GCP Workload Identity Federation for all GitHub Action workflows.

Trade-off: Requires initial setup of Workload Identity Pools and IAM bindings in GCP, but completely removes the security risk of leaked long-lived JSON service account keys.

---

### Terminal Commands to Complete Assessment Submission

Save `README.md` and execute the following commands in your terminal to complete your git history and push the entire solution:

```powershell
git add README.md docs/
git commit -m "docs: finalize executive README and submission deliverables"
git push origin oidc-test


