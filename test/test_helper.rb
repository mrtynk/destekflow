ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # ApprovalConcurrencyTest opens its own database threads and deliberately
    # disables transactional fixtures. Running unrelated fixture tests beside it
    # lets its cleanup delete their rows, so keep the suite deterministic while
    # preserving the explicit two-thread race test.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
