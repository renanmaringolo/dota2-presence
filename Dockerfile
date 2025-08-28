FROM ruby:3.3.5-alpine

# Install system dependencies
RUN apk add --no-cache \
    postgresql-dev \
    build-base \
    git \
    nodejs \
    npm \
    tzdata

# Set working directory
WORKDIR /app

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application
COPY . .

# Expose port
EXPOSE 3000

# Start server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]