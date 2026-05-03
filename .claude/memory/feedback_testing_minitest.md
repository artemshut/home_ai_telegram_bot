---
name: Use Minitest for testing
description: Testing framework preference for this project
type: feedback
---

Use **Minitest** for all tests in this project.

**Why:** Rails 8 uses Minitest as the default testing framework. It's built-in, lightweight, and well-integrated with Rails.

**How to apply:** When writing tests, use Minitest (in the `test/` directory). Run tests with `rails test` or specific test files with `rails test test/path/to/test.rb`. Organize tests by model, controller, integration, and system tests following Rails conventions.
