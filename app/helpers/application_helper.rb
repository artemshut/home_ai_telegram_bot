module ApplicationHelper
  STATUS_BADGE = {
    "pending"   => "inline-block px-2 py-0.5 rounded text-xs bg-yellow-100 text-yellow-800",
    "running"   => "inline-block px-2 py-0.5 rounded text-xs bg-blue-100 text-blue-800",
    "completed" => "inline-block px-2 py-0.5 rounded text-xs bg-green-100 text-green-800",
    "failed"    => "inline-block px-2 py-0.5 rounded text-xs bg-red-100 text-red-800"
  }.freeze

  def status_badge_class(status)
    STATUS_BADGE.fetch(status.to_s, "inline-block px-2 py-0.5 rounded text-xs bg-gray-100 text-gray-800")
  end
end
