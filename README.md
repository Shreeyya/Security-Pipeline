# myapp

Minimal Flask service, containerized, with a DevSecOps pipeline
(`.github/workflows/security-pipeline.yml`) covering SAST, SCA, secret
scanning, container scanning, DAST, and SBOM generation.

## Run locally

```bash
pip install -r requirements.txt
python app.py
# → http://localhost:8080
```

## Run in Docker

```bash
docker build -t myapp .
docker run -p 8080:8080 myapp
```

## CI/CD

See `.github/workflows/security-pipeline.yml`. Requires the `SNYK_TOKEN`
repository secret to be set (Settings → Secrets and variables → Actions).
