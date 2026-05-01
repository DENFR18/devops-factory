# GitLab CI/CD Variables — Setup & Maintenance

> **Contract**: this project requires exactly **3 variables** configured manually in GitLab.
> Everything else (buckets, cluster, namespaces, ArgoCD) is created by the pipelines.

---

## Required variables

| Variable | Protected | Masked | Description |
|---|:---:|:---:|---|
| `SCW_ACCESS_KEY` | ✅ | ✅ | Scaleway IAM API key ID |
| `SCW_SECRET_KEY` | ✅ | ✅ | Scaleway IAM API key secret |
| `SCW_DEFAULT_PROJECT_ID` | ✅ | ❌ | Scaleway project UUID |

All three must be scoped to **protected branches** (`main`, `develop`).

---

## Where to find the values

### SCW_ACCESS_KEY and SCW_SECRET_KEY

1. Log in to [console.scaleway.com](https://console.scaleway.com).
2. Click your avatar (top-right) → **IAM** → **API Keys**.
3. Click **Generate an API key**.
4. Set **Description**: `devops-factory-gitlab-ci`.
5. Set **Expiration**: 90 days (see [rotation procedure](#api-key-rotation) below).
6. Copy the **Access Key ID** → `SCW_ACCESS_KEY`.
7. Copy the **Secret Key** — shown only once → `SCW_SECRET_KEY`.

The key must belong to an IAM application or user with at minimum:

- `ObjectStorageBucketsWrite` (to let the bootstrap job create state buckets)
- `KapsuleFullAccess` (to provision and manage the Kapsule cluster)
- `RegistryFullAccess` (to push/pull container images)

### SCW_DEFAULT_PROJECT_ID

1. In the Scaleway console, navigate to **Project Settings** (sidebar).
2. Copy the **Project ID** (UUID format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).

---

## Adding variables to GitLab

1. Open your GitLab project.
2. Navigate to **Settings → CI/CD → Variables**.
3. Click **Add variable** for each of the three variables.
4. For `SCW_ACCESS_KEY` and `SCW_SECRET_KEY`:
   - Check **Protect variable** ✅
   - Check **Mask variable** ✅
   - **Expand variable reference**: leave unchecked
5. For `SCW_DEFAULT_PROJECT_ID`:
   - Check **Protect variable** ✅
   - Leave **Mask variable** unchecked (UUIDs are not sensitive but scoped to protect)
6. Click **Add variable**.

---

## API key rotation (every 90 days)

1. Go to Scaleway console → **IAM → API Keys**.
2. Create a **new** API key with the same permissions.
3. In GitLab, update `SCW_ACCESS_KEY` and `SCW_SECRET_KEY` with the new values.
4. Trigger a pipeline on `develop` to verify the new key works (`terraform-plan-dev` must pass).
5. Delete the old API key in Scaleway console.

> Set a calendar reminder 80 days after each rotation so you have 10 days of overlap.

---

## Onboarding a new collaborator

1. Add them to the GitLab project with **Developer** role (or higher).
2. Share the Scaleway project via **IAM → Members** (read-only or editor).
3. They do **not** need local Scaleway CLI or Terraform — the pipeline handles everything.
4. Point them to the [Quickstart from zero](../../README.md#quickstart-from-zero) section in the README.

---

## Variable scopes reference

| Variable | Environment scope | Notes |
|---|---|---|
| `SCW_ACCESS_KEY` | All | Single key for all envs; rotate together |
| `SCW_SECRET_KEY` | All | Single key for all envs; rotate together |
| `SCW_DEFAULT_PROJECT_ID` | All | One Scaleway project hosts dev + prod |
| `TF_STATE_BUCKET_DEV` | Defined in pipeline YAML | Not a GitLab variable |
| `TF_STATE_BUCKET_PROD` | Defined in pipeline YAML | Not a GitLab variable |
| `SCW_DEFAULT_REGION` | Defined in pipeline YAML | `fr-par` |
| `SCW_DEFAULT_ZONE` | Defined in pipeline YAML | `fr-par-1` |
