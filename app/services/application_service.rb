# Base class for all service objects
# Usage:
#   result = MyService.call(params)
#
class ApplicationService
  def self.call(...)
    new(...).call
  end
end
