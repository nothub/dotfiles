# CI Pipeline Templates

Ready-made CI and release-tooling templates. Use alongside the `ci-cd-and-automation` and `git-workflow-and-versioning` skills.

## Forgejo Actions

### Go project CI

```yaml
# .forgejo/workflows/ci.yml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6

      - uses: actions/setup-go@v6
        with:
          go-version-file: go.mod
          check-latest: true
          cache: true

      - run: go vet ./...
      - run: go test -race -count=1 ./...
      - run: go build ./...

      - name: govulncheck
        run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...
```

### Shell project CI

```yaml
  check:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
      - name: shellcheck
        run: find . -name '*.sh' -exec shellcheck {} +
```

### Release on tag (semver)

```yaml
# .forgejo/workflows/release.yml
name: Release

on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - uses: actions/setup-go@v6
        with:
          go-version-file: go.mod
          check-latest: true
          cache: true

      - run: CGO_ENABLED=0 go build -trimpath -o {{project-name}} .
```

### Notes

- Not all GitHub marketplace actions are available on Forgejo. Prefer shell steps (`run:`) over third-party actions when possible.
- For Forgejo package registry (container images): use `docker login ${{ vars.FORGEJO_URL }}` with a token stored in secrets.
- Forgejo runners are self-hosted; ensure the runner label matches (`runs-on: ubuntu-latest` maps to whatever label your runner has).

## Jenkins

Work SCM is SCM-Manager, CI is Jenkins. SCM-Manager triggers Jenkins via webhook on push/PR.

### Declarative pipeline (Go project)

```groovy
// Jenkinsfile
pipeline {
    agent { label 'linux' }

    options {
        timeout(time: 15, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Vet') {
            steps { sh 'go vet ./...' }
        }

        stage('Test') {
            steps {
                sh 'go test -race -count=1 ./... 2>&1 | tee test-output.txt'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'test-output.txt', allowEmptyArchive: true
                }
            }
        }

        stage('Build') {
            steps { sh 'go build ./...' }
        }
    }

    post {
        failure {
            // notify via whatever channel the team uses
            echo "Build failed: ${env.BUILD_URL}"
        }
    }
}
```

### Parallel stages in Jenkins

```groovy
stage('Quality') {
    parallel {
        stage('vet')  { steps { sh 'go vet ./...' } }
        stage('test') { steps { sh 'go test ./...' } }
    }
}
```

### Jenkins secrets

Use Jenkins credentials store, not hardcoded values. Access via:

```groovy
withCredentials([string(credentialsId: 'deploy-token', variable: 'TOKEN')]) {
    sh 'deploy.sh "$TOKEN"'
}
```
