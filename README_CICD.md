# Spam Classification — DVC + GitHub Actions + AWS CI/CD

This scaffold wires your existing pipeline (data ingestion → preprocessing → features → model → evaluation) to
a reproducible DVC pipeline, runs tests in CI, and pushes artifacts/metrics to an S3 DVC remote on merges to `main`.

## Project layout (key files)
- `src/` — your Python stages (`data_ingestion.py`, `data_preprocessing.py`, `feature_engineering.py`, `model_building.py`, `model_evaluation.py`)
- `dvc.yaml` — pipeline definition (stages & artifacts)
- `params.yaml` — tunable parameters
- `reports/metrics.json` — evaluation metrics tracked by DVC
- `dvclive/` — experiment logs from dvclive
- `.github/workflows/ci-cd-dvc.yaml` — CI/CD pipeline
- `aws/` — IAM policy and GitHub OIDC trust policy examples

## One-time local setup
```bash
pip install -r requirements.txt
dvc init
git add .dvc .gitignore
git commit -m "Initialize DVC"
# Configure your S3 bucket as DVC remote
dvc remote add -f aws s3://YOUR_DVC_BUCKET/path
dvc remote default aws
git add .dvc/config
git commit -m "Configure DVC remote"
```

## Run the pipeline locally
```bash
make dvc-repro
dvc metrics show
dvc push        # pushes data/model/plots to S3
```

## GitHub Actions secrets to set
- `AWS_ROLE_TO_ASSUME` — ARN of the IAM role with S3 access for DVC
- `AWS_REGION` — e.g., `ap-south-1`
- `DVC_S3_URL` — e.g., `s3://YOUR_DVC_BUCKET/path`

The workflow authenticates to AWS via GitHub OIDC (no long-lived keys).

## AWS IAM
1. Create an IAM role with:
   - **Trust policy**: `aws/github-oidc-trust-policy.json` (edit to your org/repo and account).
   - **Permissions policy**: `aws/dvc-s3-policy.json` (edit bucket names).
2. Grant the role permissions to your S3 bucket.
3. Put the role ARN in `AWS_ROLE_TO_ASSUME` secret.

## Notes
- The pipeline calls your stage scripts with `python -m src.<module>`; ensure `src/__init__.py` exists (we created an empty one).
- `dvc.yaml` declares artifacts under `data/`, `model/`, and `reports/`. DVCLive outputs are tracked in `dvclive/`.
- Unit tests run before training in CI; they import modules from `src/`.
- Tweak `params.yaml` to retune TF-IDF and RandomForest.
- On push to `main`, CI reproduces the pipeline and `dvc push` uploads artifacts/metrics to S3.

_Generated: 2025-08-20_
