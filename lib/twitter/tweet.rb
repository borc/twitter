require 'twitter/creatable'
require 'twitter/entities'
require 'twitter/identity'

module Twitter
  class Tweet < Twitter::Identity
    include Twitter::Creatable
    include Twitter::Entities
    # @return [String]
    attr_reader :filter_level, :in_reply_to_screen_name, :lang, :source
    # @return [Integer]
    attr_reader :favorite_count, :in_reply_to_status_id, :in_reply_to_user_id,
                :retweet_count
    # @return [Array<Integer>]
    attr_reader :display_text_range
    alias in_reply_to_tweet_id in_reply_to_status_id
    alias reply? in_reply_to_user_id?
    object_attr_reader :GeoFactory, :geo
    object_attr_reader :Metadata, :metadata
    object_attr_reader :Place, :place
    object_attr_reader :Tweet, :retweeted_status
    object_attr_reader :Tweet, :quoted_status
    alias retweeted_tweet retweeted_status
    alias retweet? retweeted_status?
    alias retweeted_tweet? retweeted_status?
    alias quoted_tweet quoted_status
    alias quote? quoted_status?
    alias quoted_tweet? quoted_status?
    alias extended_mode? display_text_range?
    object_attr_reader :User, :user, :status
    predicate_attr_reader :favorited, :possibly_sensitive, :retweeted,
                          :truncated

    def to_h
      attrs.merge(text: text)
    end
    alias to_hash to_h

    # @note May be > 140 characters.
    # @return [String]
    def full_text
      if retweet?
        prefix = text[/\A(RT @[a-z0-9_]{1,20}: )/i, 1]
        [prefix, retweeted_status.text].compact.join
      else
        text
      end
    end
    memoize :full_text

    # @return [Addressable::URI] The URL to the tweet.
    def uri
      Addressable::URI.parse("https://twitter.com/#{user.screen_name}/status/#{id}") if user?
    end
    memoize :uri
    alias url uri

    # @return [String]
    def text
      if extended_mode?
        @attrs[:full_text].send(:[], *display_text_range)
      else
        attr_falsey_or_empty?(:text) ? NullObject.new : @attrs[:text]
      end
    end
    memoize :text

    # @return [Boolean]
    def text?
      text.is_a?(String) && !text.empty?
    end
    memoize :text?
  end
end
