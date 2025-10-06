# News Portal

A Ruby on Rails application.

## Getting Started

### Prerequisites

- Ruby (see `.ruby-version` for the required version)
- Rails (see `Gemfile`)
- PostgreSQL
- Node.js & Yarn (if using JS dependencies)

### Setup

```sh
git clone <repo-url>
cd news_portal
cp .env.example .env # Set up your environment variables
bundle install
yarn install         # If using Yarn
bin/setup            # Runs setup tasks (db:create, db:migrate, etc.)
rails generate rspec:install # Set up RSpec (run once)
```

### Environment Variables

- All sensitive configuration (database, credentials) should be set in `.env` (never commit this file).
- See `.env.example` for required variables.

### Database

```sh
rails db:create
rails db:migrate
rails db:seed
```

> **Note:**  
> If you see an error like  
> `/home/runner/work/news_portal/news_portal/db/schema.rb doesn't exist yet. Run 'bin/rails db:migrate' to create it, then try again.`  
> you need to run:
> 
> ```sh
> bin/rails db:migrate
> ```
> 
> This will generate `db/schema.rb`.  
> If you do not intend to use a database, you can edit `config/application.rb` to limit the frameworks that are loaded.

### Running the App

```sh
rails server
```

### Running Tests

```sh
bundle exec rspec    # RSpec (main test framework)
rails test           # If using Minitest
```

> **To run all RSpec tests:**
> ```sh
> bundle exec rspec
> ```
>
> **To run a specific test file:**
> ```sh
> bundle exec rspec spec/path/to/your_spec.rb
> ```
>
> **To run a specific test by line number:**
> ```sh
> bundle exec rspec spec/path/to/your_spec.rb:42
> ```

## Best Practices

- Use environment variables for all secrets and credentials.
- Never commit `.env` or credentials to version control.
- Use feature branches and submit pull requests for all changes.
- Write tests for new features and bug fixes.
- Follow the style guide enforced by RuboCop (`bundle exec rubocop`).
- Use `brakeman` for security checks (`bundle exec brakeman`).
- Keep dependencies up to date (`bundle update`).
- Document any new environment variables or setup steps in this README.
- Use RSpec for all new tests.
- Use FactoryBot for test data and Faker for generating fake data.
- Clean up test data using DatabaseCleaner.

## Team Workflow

- Use descriptive branch names (e.g., `feature/user-auth`, `bugfix/fix-login`).
- Review pull requests before merging.
- Communicate blockers or issues in the team channel.
- Keep the main branch deployable at all times.
- Run tests locally before pushing.

## Deployment

- Ensure all environment variables are set on the server.
- Run migrations after deploying new code.
- Use `kamal` or your preferred deployment tool.

## Useful Commands

```sh
rails console
rails dbconsole
rails routes
rails logs
```

## Linting and Pre-commit Hooks

- **Ruby:** RuboCop (`bundle exec rubocop`)
- **JavaScript:** ESLint (`npx eslint app/javascript`)
- **Views:** ERB Lint (`bundle exec erblint app/views`)
- **EditorConfig:** Enforced via pre-commit
- **Test Coverage:** Pre-commit checks for 100% coverage in Ruby (RSpec) and JS (Jest, if present)

### Setup

1. Install pre-commit:
   ```sh
   pip install pre-commit
   ```
2. Install the hooks:
   ```sh
   pre-commit install
   ```
3. For JS linting, install dependencies:
   ```sh
   npm install eslint --save-dev
   ```
4. For ERB linting, add to Gemfile:
   ```ruby
   gem 'erb_lint', require: false
   ```
   Then run:
   ```sh
   bundle install
   ```

### Testing Pre-commit

To verify that pre-commit is working, make a small change to any file (for example, add a space or comment), then run:

```sh
pre-commit run --all-files
```

This will execute all configured hooks on your codebase.  
If you try to commit with `git commit`, the hooks should also run automatically and block the commit if any checks fail.

## Contributing

- Fork the repo and create your branch from `main`.
- Ensure code passes all tests and lints.
- Submit a pull request with a clear description.

## License

MIT
