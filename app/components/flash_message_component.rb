class FlashMessageComponent < ApplicationComponent
  attr_reader :type, :message

  def initialize(type:, message:)
    @type = type
    @message = message
  end
  
  private

  def color_classes
    case type
    when :success
      'bg-green-100 border-green-400 text-green-700'
    when :error
      'bg-red-100 border-red-400 text-red-700'
    when :warning
      'bg-yellow-100 border-yellow-400 text-yellow-700'
    when :notice
      'bg-blue-100 border-blue-400 text-blue-700'
    else
      'bg-gray-100 border-gray-400 text-gray-700'
    end
  end
end