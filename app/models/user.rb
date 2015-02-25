class User < ActiveRecord::Base
  before_save { screen_name.downcase! }

  extend FriendlyId
  friendly_id :screen_name

  mount_uploader :profile_image, ProfileImageUploader

  validates :screen_name,
    presence: true,
    length: { maximum: 15 },
    format: { with: /\A[[:alpha:]_][[:alnum:]_]*\Z/ },
    uniqueness: { case_sensitive: false }
  # hack to use multiple format validations
  validates :screen_name,
    format: { without: /\A[[:digit:]_]+\Z/ }

  validates :name,
    presence: true

  validates :description,
    length: { maximum: 160 }


  scope :newer, ->() {
    order(created_at: :desc)
  }


  # XXX: if 'devise' declaration is defined in 'included' block in concerning, 
  #      raise 'PG::UndefinedColumn: ERROR: column users.login does not exist'
  #      so, we should defined it here...
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :omniauthable, omniauth_providers: Devise.omniauth_providers,
    :authentication_keys => [:login]

  concerning :Authenticatable do
    included do
      # virtual field for screen_name or email
      attr_accessor :login

      has_many :authentications, dependent: :destroy
    end

    def apply_omniauth(omniauth)
      self.name  = omniauth['info']['name']  if name.blank?
      self.email = omniauth['info']['email'] if email.blank?

      authentications.build(
        provider: omniauth['provider'],
        uid: omniauth['uid'],
        account_name: omniauth['info']['_account_name'],
        url: omniauth['info']['_url']
      )
    end

    def password_required?
      (authentications.empty? || !password.blank?) && super
    end

    class_methods do
      def find_first_by_auth_conditions(warden_conditions)
        conditions = warden_conditions.dup
        if login = conditions.delete(:login)
          where(conditions).where(["lower(screen_name) = :value OR lower(email) = :value", {
            value: login.downcase
          }]).first
        else
          where(conditions).first
        end
      end
    end
  end


  concerning :MessageOwnable do
    included do
      has_many :messages, dependent: :destroy

      # reply relationships that the user received from
      has_many :reverse_reply_relationships, foreign_key: 'to_user_id',
                                             class_name: 'Reply',
                                             dependent: :destroy
      has_many :replies_received, through: :reverse_reply_relationships, source: :message
    end

    def timeline
      Message.timeline_of(self)
    end

    # replies that the user sent
    def replies
      messages.joins(:reply_relationships).distinct
    end

    def messages_without_replies
      messages.includes(:reply_relationships).where(replies: {id: nil}).references(:reply_relationships)
    end

    def mentions(filter: nil)
      Message.mentions_of(self, filter: filter)
    end
  end


  concerning :Followable do
    included do
      # following relationships
      has_many :follow_relationships, foreign_key: 'follower_id',
                                      class_name: 'Follow',
                                      dependent: :destroy
      has_many :followed_users, through: :follow_relationships, source: :followed

      # followers relationships
      has_many :reverse_follow_relationships, foreign_key: 'followed_id',
        class_name: 'Follow',
        dependent: :destroy
      has_many :followers, through: :reverse_follow_relationships, source: :follower
    end

    def followed_users_newer
      followed_users.merge(Follow.order(created_at: :desc))
    end

    def followers_newer
      followers.merge(Follow.order(created_at: :desc))
    end

    def following?(other_user)
      follow_relationships.find_by(followed_id: other_user.id)
    end

    def follow!(other_user)
      follow_relationships.create!(followed_id: other_user.id)
    end

    def unfollow!(other_user)
      follow_relationships.find_by(followed_id: other_user.id).destroy!
    end
  end


  concerning :Favoritable do
    included do
      has_many :favorite_relationships, class_name: 'Favorite', dependent: :destroy
      has_many :favorites, through: :favorite_relationships, source: :message
    end
  end

  concerning :Retweetable do
    included do
      has_many :retweet_relationships, class_name: 'Retweet', dependent: :destroy
      has_many :retweets, through: :retweet_relationships, source: :message
    end
  end
end
