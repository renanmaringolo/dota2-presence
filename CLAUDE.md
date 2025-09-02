# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Personal Information - Renan Proença

**Profile**: Backend Pleno Developer, DevOps enthusiast and Dota 2 streamer (known as Metallica), organizer of the amateur team Rock n Sports.

**Main Stack**: Ruby on Rails, Node.js/TypeScript (Nest), JavaScript, GraphQL, PostgreSQL, Docker, DevOps

**Objective**: Always seek solutions that make me look as SENIOR as possible, applying the best development practices.

### How Claude should respond:
- **Always in Portuguese** in chat
- **Clean, SOLID, DRY** code but without breaking existing structures
- **Simplicity first**: fewer modifications = better solution  
- In Ruby/Rails: intelligent refactoring preserving compatibility
- In Node/JS: prefer simple and direct solutions
- **Performance and quality** without giving up simplicity
- When it's an interview/technical challenge: solve + explain concepts behind
- **Always question** when something needs to be better understood
- **Teach** to accelerate my learning
- **When detecting important delivery completed**: Ask if I should update session_history.md

### Criteria for "Important Delivery":
- Implemented and working features (not just understanding)
- Fully defined and documented architectures
- Complex problems solved with validation
- Technical documentation finalized for presentation
- Project milestones achieved (refinements, final reorganizations)
- Critical integrations implemented and tested
- **DO NOT include**: Theoretical analysis, code reading, simple corrections

### Vocabulary for examples/tests:
Use terms from my context: "Lero Lero", "Bla Bla", "Trade", "OTC", "Renan Proença", "Backend", "Teste" - **never** obvious AI names.

## Project Overview

**Dota Evolution Presence** is a Ruby on Rails web application for managing daily presence in Dota 2 gaming groups. The system allows coaches (Immortal players) to organize gaming sessions with lower-rank players (Ancient and below) through WhatsApp integration and a professional web interface.

## Development Commands

### Tests
- **Run all tests:** `bundle exec rspec spec/ -f d`
- **Run specific file:** `bundle exec rspec spec/models/user_spec.rb -f d`
- **Run folder tests:** `bundle exec rspec spec/models/ -f d`
- **Run specific test:** `bundle exec rspec spec/models/user_spec.rb:[line_number] -f d`

### Rails Application
- **Start Rails server:** `bundle exec rails server`
- **Rails console:** `bundle exec rails console`
- **Start Sidekiq:** `bundle exec sidekiq`
- **Setup database:** `bundle exec rake db:create db:schema:load`
- **Seed database:** `bundle exec rake db:seed`
- **Generate secret:** `bundle exec rake secret`

### Code Quality
- **Run RuboCop:** `bundle exec rubocop`
- **Auto-fix RuboCop:** `bundle exec rubocop -a`

### Docker Development
- **Start all services:** `docker-compose up -d`
- **View logs:** `docker-compose logs -f app`
- **Run migrations:** `docker-compose exec app bundle exec rails db:migrate`
- **Rails console in Docker:** `docker-compose exec app bundle exec rails console`

## General Architecture

### Main Patterns
- **Service-Oriented Architecture:** All business logic encapsulated in service classes inheriting from `ApplicationService`
- **RESTful API:** Simple REST API with JSON responses for web interface
- **State Machines:** Use of AASM for managing entity states (daily lists, presences)
- **Background Jobs:** Sidekiq for asynchronous processing (daily list generation, WhatsApp message processing)

### Main Domain Models
- **User:** Player entity with nickname, positions, and category (immortal/ancient)
- **DailyList:** Daily generated list for organizing gaming sessions
- **Presence:** Individual confirmation per player per day with position
- **WhatsappMessage:** Incoming messages from WhatsApp group for parsing

### Service Layer
Services follow consistent patterns:
- Inherit from `ApplicationService`
- Return structured responses with success/error states
- Include comprehensive logging and error handling
- Use transactions for data consistency

### Database Architecture
- **PostgreSQL 16+:** Main database with JSON support for flexible data
- **Optimized Indexes:** Fast queries for daily lists and user lookups
- **UUID Fields:** Support for external system integration
- **Audit Trail:** Complete tracking of presence confirmations

## Development Guidelines

### Code Style
- Follow Ruby Style Guide conventions
- Use RuboCop for linting
- Write code and comments only in English
- Portuguese allowed for PR descriptions and discussions

### API Conventions
- **RESTful Routes:** Use standard Rails routes for admin interface
- **JSON Responses:** Consistent JSON structure for API endpoints
- **Error Handling:** Proper HTTP status codes and error messages
- **Authentication:** Simple token-based auth for admin, public access for presence confirmation

### Service Development
- Encapsulate complex business logic in dedicated service classes
- Use `service_response(success, data)` for consistent return values
- Implement proper error logging with `Rails.logger`
- Follow transaction patterns for data consistency

### Security Considerations
- Implement comprehensive input validation
- Use proper authentication checks in admin controllers
- Rate limiting for public endpoints
- Secure WhatsApp webhook endpoint with proper validation

## Testing Strategy

### Test Structure
- **Models:** Focus on validations, associations and business logic
- **Services:** Test success/failure paths and edge cases
- **Controllers:** Test API endpoints with proper authentication
- **Integration:** End-to-end tests with Capybara for critical flows

### Test Configuration
- Uses RSpec with extensive factory configuration via FactoryBot
- Chrome headless for feature tests (configurable with HEADLESS env var)
- DatabaseCleaner for test data isolation
- WebMock for stubbing external services (WhatsApp API)

## Development Environment

### Prerequisites
- Ruby 3.2+
- Rails 7.1+
- Docker and Docker Compose
- PostgreSQL 16+, Redis 7+ (provided via Docker)

### Local Setup
1. Clone repository: `git clone git@github.com-pessoal:renanproenca/dota-evolution-presence.git`
2. Setup with Docker: `docker-compose up -d`
3. Run migrations: `docker-compose exec app bundle exec rails db:migrate`
4. Seed database: `docker-compose exec app bundle exec rails db:seed`

### Important Environment Variables
- `SECRET_KEY_BASE`: Application secret key
- `REDIS_URL`: Redis connection for cache and sessions
- `DATABASE_URL`: PostgreSQL connection string
- `WHATSAPP_WEBHOOK_SECRET`: Secret for WhatsApp webhook validation

## Important File Patterns

### Configuration Files
- `config/application.yml.example`: Environment variables template
- `config/sidekiq.yml`: Background job queue configurations
- `docker-compose.yml`: Development environment setup

### Service Classes
- `app/services/`: Business logic implementation
- `app/services/daily_list_generator.rb`: Generates daily presence lists
- `app/services/whatsapp/message_parser.rb`: Parses WhatsApp messages
- Services return structured responses and handle errors consistently

### Controller Implementation
- `app/controllers/admin/`: Admin interface controllers
- `app/controllers/presences_controller.rb`: Public presence confirmation
- `app/controllers/whatsapp_webhook_controller.rb`: WhatsApp integration

### Background Jobs
- `app/jobs/`: Sidekiq job classes
- `app/jobs/generate_daily_list_job.rb`: Creates daily lists automatically
- `app/jobs/process_whatsapp_message_job.rb`: Processes incoming WhatsApp messages

## Debug and Development Tips

### Local Development
- Use `rails console` to test services and models interactively
- Check Sidekiq web interface at `http://localhost:4567` when running
- Use `docker-compose logs -f app` to monitor application logs

### WhatsApp Integration Debug
- Test message parsing with `Whatsapp::MessageParser.new(phone, message).parse!`
- Monitor webhook calls in development logs
- Use ngrok for testing webhooks locally

## Common Development Flows

### Adding New User
- Use admin interface or Rails console
- Set nickname, positions array, and category
- Test with presence confirmation

### Implementing New Service
- Inherit from `ApplicationService`
- Implement business logic with proper error handling
- Add corresponding background job if necessary
- Create comprehensive tests covering success/failure paths

### Adding New Controller Endpoint
- Follow RESTful conventions
- Add proper authentication if needed
- Return consistent JSON responses
- Add tests for the endpoint

## Dota Evolution Presence Context

### Business Model
Service that connects Immortal-rank Dota 2 coaches with lower-rank players (Ancient and below) for live gaming sessions with real-time coaching.

**Characteristics:**
- R$ 5 per game session
- Live coaching during gameplay
- Daily presence management via WhatsApp groups
- Two categories: Immortal (coaches) and Ancient (students)
- Sessions typically 12-16h but also evening games

### Position System
- **P1/HC (Hard Carry)**: Main damage dealer, position 1
- **P2/MID**: Mid lane, position 2  
- **P3/Offlaner**: Offlane, position 3
- **P4/Support**: Roaming support, position 4
- **P5/Hard Support**: Ward support, position 5

### Daily Flow
1. Coach generates daily list (manual or automated)
2. Players confirm presence via WhatsApp message: "Nickname/P1"
3. System parses message and validates position
4. List is updated in real-time
5. Coach organizes games based on confirmed players

**Tech Stack:** Ruby/Rails 7.1 + PostgreSQL 16 + Docker + WhatsApp Integration

## Communication and Response Guidelines

### Communication Efficiency
- Be concise, direct to the point
- Minimize tokens while maintaining collaboration and precision
- Stop after completing tasks - avoid unnecessary explanations
- One-word answers are adequate when appropriate
- Respond directly without elaboration
- No emojis unless explicitly requested

### Content Creation
- DO NOT add placeholders in edits
- DO NOT add code comments unless requested
- NEVER create documentation files (*.md) or README unless requested
- Do not create example or demonstration files
- Do not add unnecessary documentation
- Do not explain obvious things

## Implementation Patterns

### Code Quality
- Check existing patterns in neighboring files before implementing
- Maintain backward compatibility
- Ensure backward compatibility when refactoring
- Do not create new files when editing existing ones would work
- Do not over-engineer solutions

### Functional Approaches
- Prefer functional approaches with reduce, map, filter
- Extract helper functions outside main ones for clean code
- Use descriptive and semantic names
- Main functions should be clean chains of transformations
- Prefer structured data over string parsing

### Maintenance and Refactoring
- Maintain all existing functionality when refactoring
- Observe patterns in similar files/components
- Pay attention to current branch context and diff with main

## Debugging Strategy

### Problem Identification
- Identify root cause first when something breaks
- Fix root cause, not symptoms
- Verify if data structure matches implementation

### Testing Flow
- Always run tests after changes
- Fix broken tests and study complete flow
- Read tests carefully when they break
- Look for related files (inheritances, neighboring components)
- Always use rspec-mocha instead of rspec-mocks

## Work Context

### Task Management
- Attention to PARENT/CHILD tasks - usually continuations
- Consider current branch context and differences with main
- Pay attention to specific branches when mentioned

### Branch Naming Pattern (en-US)

General format: `<type>/<description>`

#### 📌 Allowed Prefixes

| Type | Prefix | Example |
|----|----|----|  
| New feature | `feat` | `feat/add-whatsapp-integration` |
| Bug fix | `bug` | `bug/fix-presence-validation` |
| Enhancement | `enhance` | `enhance/improve-daily-list-ui` |
| Hotfix | `fix` | `fix/urgent-webhook-error` |

💡 **Tips**:

* Use descriptive and clear names in the description part
* Avoid very long or generic names
* Always keep names in *kebab-case* (lowercase with hyphens)

### Pull Request Template

Simple template for Dota Evolution Presence PRs. Fill organically, in first person, without unnecessary flourishes.

```markdown
## What was done

[Describe the changes made]

## Why

[Explain the motivation for these changes]

## Testing

- [ ] Tests added/updated
- [ ] Manual testing completed
- [ ] No breaking changes

## Additional Notes

[Any additional information, deployment notes, etc.]
```

**Filling guidelines:**
- Write organically in first person
- Don't embellish - be direct and objective
- Focus on the essential: what was done and why