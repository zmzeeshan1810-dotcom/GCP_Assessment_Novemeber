# Incident Response & Operational Runbook

## 1. Executive Summary
This runbook defines operational procedures for triaging incidents, performing emergency rollbacks, resolving state locks, and executing zero-downtime cutovers for the Java Spring Boot microservice deployed on GCP Cloud Run via Terraform and GitHub Actions.

---

## 2. Emergency Rollback Procedures

### 2.1 Instant Revision Traffic Splitting (P1 Incident)
If a newly deployed container version introduces severe bugs or elevated 5xx error rates, roll back traffic immediately using Cloud Run's immutable revision traffic splitting.

#### **Step 1: Identify Previous Healthy Revision**
```bash
gcloud run revisions list \
  --service=stateless-app-prod \
  --region=us-central1 \
  --format="table(name,active,creationTimestamp)"

Step 2: Shift 100% Traffic to Previous Revision

gcloud run services update-traffic stateless-app-prod \
  --region=us-central1 \
  --to-revisions=stateless-app-prod-00042-xyz=100

Effect: Traffic redirects to the prior immutable revision in under 5 seconds without destroying the broken revision, allowing post-mortem analysis.

3. Terraform State Lock Recovery
3.1 Resolving Stale Backend Locks
If a GitHub Actions pipeline crashes or is manually terminated while running terraform apply, the GCS remote backend state bucket will remain locked.

Step 1: Identify Lock ID
When running terraform plan or terraform apply, Terraform displays the lock error:
Error: Error acquiring the state lock: GCS bucket lock acquire failed
Lock Info:
  ID: 1730985600000000
  Path: optum-tf-state-prod-us-central1/cloud-run/stateless-app/prod/default.tflock

Step 2: Force Unlock the Backend
Execute from the local terminal (requires GCS Storage Admin permissions):
cd terraform
terraform force-unlock -force 1730985600000000

4. Container Crash-Loop & JVM Triage
4.1 JVM Out-Of-Memory (OOM) Analysis
If Cloud Run instances crash-loop with Memory limit exceeded:

Query Logs in GCP Cloud Logging:
resource.type="cloud_run_revision"
resource.labels.service_name="stateless-app-prod"
severity>=ERROR
"OutOfMemoryError" OR "Memory limit exceeded"

Immediate Remediation: Temporarily increase container RAM via prod.tfvars:
memory = "2048Mi"

Root Cause Analysis: Inspect JVM heap allocation in Spring Boot via /actuator/metrics/jvm.memory.used.

4.2 Probe Failures (/health & /ready)
If Cloud Run reports Container failed to start. Failed to listen on port 8080:

Check /ready endpoint response: Ensure Spring Boot startup time does not exceed initial_delay_seconds (5s) + failure_threshold (10 tries).

Verify JVM port binding: Ensure Spring Boot reads PORT environment variable (server.port=${PORT:8080}).

5. Zero-Downtime Deployment & Database Schema Cutover
To safely execute zero-downtime database migrations (e.g., Cloud SQL with Spring Boot Liquibase/Flyway):
[ Phase 1: Expand ]       [ Phase 2: Deploy ]       [ Phase 3: Contract ]
Add new column/table  ---> Deploy app code using  ---> Drop old column/table
(Backward Compatible)      new DB schema              in subsequent release

Backward Compatibility: Ensure DB migrations are additive (new columns added as NULLable or with defaults).

Canary Deployment: Deploy new Cloud Run revision serving 10% of production traffic:
gcloud run services update-traffic stateless-app-prod \
  --region=us-central1 \
  --to-revisions=stateless-app-prod-00043-new=10,stateless-app-prod-00042-old=90

Full Cutover: After monitoring metrics for 15 minutes, promote to 100% traffic.

---

Save `docs/incident-response.md` and run these commands to commit and push:

```powershell
git add docs/incident-response.md
git commit -m "docs: add incident response runbook"
git push origin oidc-test

With Step 3 complete, we are ready for Step 4 (Final Step): Executive Submission README.md.