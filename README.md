# News Portal

A Ruby on Rails application.

## Tech Stack

- **Ruby** 3.4.7
- **Rails** 8.1.2
- **Database** PostgreSQL
- **Frontend** Hotwire (Turbo + Stimulus), Import Maps
- **Assets** Propshaft
- **Web Server** Puma
- **Background Jobs** Solid Queue
- **Caching** Solid Cache
- **WebSockets** Solid Cable
- **Deployment** Kamal + Docker

## Getting Started

### Prerequisites

- Ruby 3.4.7 (see `.ruby-version`)
- Rails 8.1.2 (see `Gemfile`)
- PostgreSQL 9.3+
- RVM (or rbenv/asdf for Ruby version management)

### Setup

```sh
git clone <repo-url>
cd news_portal
cp .env.example .env   # Copy and fill in your environment variables
bundle install
bin/setup-hooks        # Install git hooks (required for all developers)
bin/setup              # Runs db:create, db:migrate, and starts the server
```

### Environment Variables

All sensitive configuration is managed via `.env` (never commit this file).
See `.env.example` for required variables:

| Variable | Description |
|----------|-------------|
| `NEWS_PORTAL_DEVELOPMENT_DB` | Development database name |
| `NEWS_PORTAL_DEVELOPMENT_USER` | Development database username |
| `NEWS_PORTAL_DEVELOPMENT_PASSWORD` | Development database password |
| `NEWS_PORTAL_DEVELOPMENT_HOST` | Development database host |
| `NEWS_PORTAL_DEVELOPMENT_PORT` | Development database port |
| `NEWS_PORTAL_TEST_DB` | Test database name |
| `NEWS_PORTAL_TEST_USER` | Test database username |
| `NEWS_PORTAL_TEST_PASSWORD` | Test database password |
| `NEWS_PORTAL_TEST_HOST` | Test database host |
| `NEWS_PORTAL_TEST_PORT` | Test database port |
| `MAILER_FROM` | Default sender email address |
| `APP_HOST` | Production hostname (for DNS rebinding protection) |

### Database

```sh
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### Running the App

```sh
bin/rails server
```

The app will be available at `http://localhost:3000`. Health check endpoint: `GET /up`

## Running Checks Before Pushing

Run all checks with a single command to ensure no bad code is pushed:

```sh
bin/ci
```

### Individual Checks

| Check | Command | Purpose |
|-------|---------|---------|
| RuboCop | `bundle exec rubocop` | Code style & linting |
| Brakeman | `bin/brakeman --no-pager` | Security vulnerability scan |
| Bundle Audit | `bundle exec bundle-audit check --update` | Gem vulnerability scan |
| Importmap Audit | `bin/importmap audit` | JS dependency vulnerability scan |
| Minitest | `bin/rails test` | Unit & system tests |
| RSpec | `bundle exec rspec` | BDD tests |

### Running Tests

```sh
# Run all RSpec tests
bundle exec rspec

# Run a specific test file
bundle exec rspec spec/path/to/your_spec.rb

# Run a specific test by line number
bundle exec rspec spec/path/to/your_spec.rb:42

# Run Minitest
bin/rails test

# Run system tests
bin/rails test:system
```

## Security

This project includes the following security measures:

- **Content Security Policy (CSP)** - Strict policy with nonce-based script/style protection
- **Rate Limiting** - Rack::Attack for request throttling (login, password reset, general requests)
- **Password Hashing** - bcrypt via `has_secure_password`
- **Parameter Filtering** - Sensitive params (passwords, tokens, API keys, JWTs) filtered from logs
- **DNS Rebinding Protection** - Production hosts restricted via `APP_HOST` env var
- **Bundle Audit** - Automated gem vulnerability scanning in CI
- **Brakeman** - Static analysis for Rails security vulnerabilities
- **Force SSL** - All production traffic forced over HTTPS

## CI/CD

GitHub Actions runs the following jobs on every PR and push to `main`:

| Job | Description |
|-----|-------------|
| `scan_ruby` | Brakeman security scan |
| `scan_gems` | Bundle Audit gem vulnerability scan |
| `scan_js` | Importmap JS dependency audit |
| `lint` | RuboCop code style check |
| `test` | Full test suite with PostgreSQL |

## Git Hooks (Enforced)

Every developer must install git hooks after cloning:

```sh
bin/setup-hooks
```

This installs two hooks that **block bad code from being committed or pushed**:

| Hook | When | What it runs |
|------|------|--------------|
| `pre-commit` | Every `git commit` | RuboCop (fast code style check) |
| `pre-push` | Every `git push` | `bin/ci` (full suite: lint, security, tests) |

> To bypass in an emergency: `git push --no-verify` (use sparingly)

## Linting

- **Ruby:** RuboCop (`bundle exec rubocop`)
- **JavaScript:** ESLint (`npx eslint app/javascript`)
- **Views:** ERB Lint (`bundle exec erblint app/views`)

## Best Practices

- Use environment variables for all secrets and credentials
- Never commit `.env` or credentials to version control
- Use feature branches and submit pull requests for all changes
- Write tests for new features and bug fixes
- Follow the style guide enforced by RuboCop
- Run all checks locally before pushing
- Keep dependencies up to date (`bundle update`)
- Use RSpec for all new tests
- Use FactoryBot for test data and Faker for generating fake data
- Clean up test data using DatabaseCleaner

## Branching Strategy

- **main**: Always deployable. Only production-ready code is merged here.
- **development** (optional): Integration branch for features before merging to `main`.
- **feature/***: For new features (e.g., `feature/user-auth`)
- **bugfix/***: For bug fixes (e.g., `bugfix/fix-login`)
- **hotfix/***: For urgent production fixes. Branch off from `main`.
- **release/***: For preparing a release.

### Workflow

1. Create a branch from `main`.
2. Work on your changes.
3. Run all checks: `bin/ci`
4. Open a pull request to merge into `development`.
5. Ensure all CI checks pass and get a review before merging.
6. After successful QA from the development env, pull request to merge into `main` from your feature branch.

## Deployment

```sh
kamal setup   # First-time deployment
kamal deploy  # Subsequent deployments
```

Ensure all production environment variables are set (see `.env.example`).

## Useful Commands

```sh
bin/rails console       # Interactive Rails console
bin/rails dbconsole     # Database console
bin/rails routes        # List all routes
bin/rails server        # Start development server
```

## Contributing

- Fork the repo and create your branch from `main`.
- Ensure code passes all checks (lint, security, tests).
- Submit a pull request with a clear description.

## License

MIT
