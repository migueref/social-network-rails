# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class PostChannel < ApplicationCable::Channel
  def subscribed
    stream_from "posts_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
