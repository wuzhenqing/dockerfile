# Contributing Guide

Thank you for your interest in this project! We welcome all kinds of contributions, including but not limited to:

- Bug reports
- Feature requests
- Pull requests
- Documentation improvements

## How to contribute

### 1. Fork the repository

Fork the repository to your own GitHub account.

### 2. Create a branch

Create a new feature branch from `main`:

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

Branch name conventions:

- `feat/` — new feature
- `fix/` — bug fix
- `docs/` — documentation update
- `refactor/` — code refactoring
- `test/` — testing-related changes

### 3. Make your changes

#### Dockerfile style guide

1. **Instruction case** — use uppercase for all Dockerfile instructions (`FROM`, `RUN`, `COPY`, etc.).
2. **Comments** — add comments for each major step explaining its purpose.
3. **Layer optimization** — combine related `RUN` instructions to reduce image layers.
4. **Security**:
   - Avoid hardcoding secrets in images.
   - Run applications as a non-root user (`ma-user` for ModelArts images).
   - Keep base images and dependencies up to date.
5. **Maintainability**:
   - Keep code clear and readable.
   - Use meaningful variable names.
   - Follow the existing style in the repository.

#### Pre-commit checks

Before submitting, please make sure:

1. **Run Hadolint** to lint Dockerfiles:

   ```bash
   # Install hadolint if you have not already
   # macOS: brew install hadolint
   # Linux: download from https://github.com/hadolint/hadolint/releases

   # Lint all Dockerfiles
   find . -name "Dockerfile*" -exec hadolint {} +
   ```

2. **Validate syntax** with Docker:

   ```bash
   docker build -f path/to/Dockerfile --check .
   ```

3. **Update documentation** if you add or change a Dockerfile.

### 4. Commit your changes

Write clear, descriptive commit messages:

```bash
git add .
git commit -m "feat: add CANN 8.4 support"
```

Commit message prefixes:

- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation update
- `style:` — formatting changes that do not affect functionality
- `refactor:` — code refactoring
- `test:` — testing-related changes
- `chore:` — build process or tooling changes

### 5. Push and open a Pull Request

```bash
git push origin feat/your-feature-name
```

Then open a Pull Request on GitHub and include:

- The purpose and background of the change
- A summary of major changes
- References to any related issues
- Testing notes, if applicable

All Pull Requests are reviewed for:

1. Code quality and style
2. Dockerfile best practices
3. Documentation completeness
4. Test coverage, if applicable

Please be patient and address any feedback you receive.

## Dockerfile best practices

### Base images

- Prefer official, maintained base images.
- Pin explicit version tags; avoid `latest`.
- Choose an appropriate base image size for your use case.

### Layer caching

```dockerfile
# Good: place slow-changing steps early
RUN apt-get update && apt-get install -y package1 package2

# Bad: place frequently changing steps before slow package installs
COPY frequently-changing-file.txt /app/
RUN apt-get update && apt-get install -y package1
```

### Reducing image size

- Use `--no-cache` when installing packages where appropriate.
- Clean package caches (`apt`, `yum`, `dnf`) in the same `RUN` layer.
- Remove temporary files and build dependencies.
- Use multi-stage builds when they help.

### Security

```dockerfile
# Good: run as a non-root user
USER ma-user
WORKDIR /home/ma-user

# Avoid: storing secrets in the image
# ENV API_KEY=secret-key  # do not do this
```

### Environment variables

- Use `ENV` for environment variables.
- Provide sensible defaults where appropriate.
- Avoid hardcoding paths and configuration values.

## Reporting issues

If you find a problem, please open an issue and include:

1. **Description** — a clear description of the problem
2. **Steps to reproduce** — how to trigger the issue
3. **Expected behavior** — what you expected to happen
4. **Actual behavior** — what actually happened
5. **Environment**:
   - Docker version
   - Operating system
   - Relevant Dockerfile path
6. **Logs** — any relevant error logs or output

## Feature requests

If you have a feature idea, please open an issue and describe:

1. **Feature description** — what you would like to see
2. **Use case** — when and why you would use it
3. **Possible implementation** — any ideas you have for how to implement it

## License

By contributing code, you agree that your contribution will be released under the same license as this project: the [MIT License](https://github.com/wuzhenqing/dockerfile/blob/main/LICENSE).

## Contact

If you have any questions, please:

- Open an issue
- Open a Pull Request and mention your question in the description

Thank you for contributing!
