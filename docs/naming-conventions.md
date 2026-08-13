# Naming Conventions

This document describes how Dockerfiles in this repository are named and organized.

## Directory layout principles

The repository uses a **project-based directory layout**:

- Each project has its own directory.
- Different versions of the same project live in the same directory.
- Platform or variant differences are expressed through the filename.

## Dockerfile naming format

### Basic format

```text
{version-tag}-{platform-tag}.Dockerfile
```

### Platform tags

#### `base` — base/local variant

- **User**: `root`
- **Working directory**: `/root`
- **pip configuration**: global (`pip config set`)
- **Use cases**:
  - Local development environments
  - Test environments
  - Scenarios that need full root privileges
  - Flexible debugging and experimentation

#### `modelarts` — ModelArts variant

- **User**: `ma-user` (UID 1000, GID 100)
- **Working directory**: `/home/ma-user`
- **pip configuration**: user-level (`pip config --user set`)
- **Use cases**:
  - Huawei Cloud ModelArts platform
  - Cloud environments that require a specific user identity
  - Multi-tenant environments

### Naming examples

#### Generic projects

| Filename | Description |
|----------|-------------|
| `dev-base.Dockerfile` | Base development image |
| `dev-modelarts.Dockerfile` | ModelArts development image |
| `prod-base.Dockerfile` | Base production image |
| `prod-modelarts.Dockerfile` | ModelArts production image |

#### Versioned projects (e.g. CANN)

| Filename | Description |
|----------|-------------|
| `8.3.RC1-base.Dockerfile` | CANN 8.3 RC1 base image |
| `8.3.RC1.alpha003-modelarts.Dockerfile` | CANN 8.3 RC1 alpha003 ModelArts image |
| `8.2.RC1.alpha002-modelarts.Dockerfile` | CANN 8.2 RC1 alpha002 ModelArts image |

#### Framework projects (multiple dependency versions)

| Filename | Description |
|----------|-------------|
| `2.7-cann8.2-modelarts.Dockerfile` | MindSpore 2.7 + CANN 8.2 ModelArts image |
| `3.0-cann8.3-base.Dockerfile` | Hypothetical MindSpore 3.0 + CANN 8.3 base image |

## Environment tags

Common environment identifiers:

- **`dev`** — development environment with full tooling and debug utilities
- **`prod`** — production environment with a minimal runtime footprint
- **`test`** — test environment with testing tools and frameworks

## Directory organization examples

### Single-project structure

```text
project-name/
├── dev-base.Dockerfile
├── dev-modelarts.Dockerfile
├── prod-base.Dockerfile
└── prod-modelarts.Dockerfile
```

### Multi-version project structure

```text
project-name/
├── 1.0-base.Dockerfile
├── 1.0-modelarts.Dockerfile
├── 2.0-base.Dockerfile
├── 2.0-modelarts.Dockerfile
└── scripts/
    └── helper.sh
```

## Supporting file names

### Scripts

- `entrypoint.sh` — container startup script
- `setup.sh` — environment setup script
- `build.sh` — build helper script

### Configuration files

- `config.yaml` — configuration file
- `requirements.txt` — Python dependencies
- `packages.list` — system package list

## Adding a new project

Follow these steps when adding a new project:

1. **Create the project directory**

   ```bash
   mkdir project-name/
   ```

2. **Create the base Dockerfile**

   ```bash
   touch project-name/dev-base.Dockerfile
   ```

3. **Create the ModelArts Dockerfile**

   ```bash
   touch project-name/dev-modelarts.Dockerfile
   ```

4. **Keep the two variants in sync**

   Except for user-specific settings, the base and ModelArts variants should share the same:

   - System packages
   - Python packages
   - Toolchain
   - Environment variables (except user paths)

5. **Update the main README**

   Add the new project to the project list in `README.md`.

## Version management recommendations

### Git tags

Create Git tags for important releases:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Docker image tags

Use clear, descriptive tags when building images:

```bash
# Semantic version
docker tag image:latest image:v1.0.0

# Build information included
docker tag image:latest image:v1.0.0-cann8.3-py3.11-ubuntu22.04

# Convenience tags
docker tag image:v1.0.0 image:v1.0
docker tag image:v1.0.0 image:v1
docker tag image:v1.0.0 image:latest
```

## Best practices

1. **Stay consistent** — use the same naming rules across all projects.
2. **Be self-descriptive** — filenames should explain themselves without extra context.
3. **Avoid redundancy** — do not repeat the project name in the filename; it is already in the directory name.
4. **Use official version numbers** — do not invent custom version identifiers.
5. **Keep documentation updated** — update docs immediately when adding new projects or variants.

## Anti-patterns (avoid)

:x: Bad names:

```text
Dockerfile                          # unclear
Dockerfile.bak                      # backup files should not be committed
asnumpy-dev-base.Dockerfile         # repeats the project name
cann_8.3_rc1_base.Dockerfile        # uses underscores, inconsistent
8.3-modelarts-final.Dockerfile      # "final" is ambiguous
```

:white_check_mark: Good names:

```text
dev-base.Dockerfile
dev-modelarts.Dockerfile
8.3.RC1-base.Dockerfile
8.3.RC1.alpha003-modelarts.Dockerfile
2.7-cann8.2-modelarts.Dockerfile
```
