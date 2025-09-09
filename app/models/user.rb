class User < ApplicationRecord
  has_secure_password

  POSITIONS = ['P1', 'P2', 'P3', 'P4', 'P5'].freeze
  CATEGORIES = ['ancient', 'immortal'].freeze
  ROLES = ['player', 'admin'].freeze

  MEDALS = ['herald', 'guardian', 'crusader', 'archon', 'legend', 'ancient', 'divine', 'immortal'].freeze

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: :password_required?
  validates :name, presence: true
  validates :nickname, presence: true
  validates :name, uniqueness: { scope: :phone, message: 'and phone combination already exists' }
  validates :phone, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :preferred_position, inclusion: { in: POSITIONS }, allow_blank: true
  validates :rank_medal, presence: true, inclusion: { in: MEDALS }
  validates :rank_stars, presence: true, inclusion: { in: 1..5 },
                         if: -> { rank_medal != 'immortal' }
  validates :rank_stars, presence: true, numericality: { greater_than: 0 },
                         if: -> { rank_medal == 'immortal' }
  validates :role, presence: true, inclusion: { in: ROLES }

  validate :positions_are_valid
  validate :category_matches_rank

  after_initialize :set_defaults, if: :new_record?
  before_validation :normalize_email
  before_validation :set_category_from_rank

  scope :active, -> { where(active: true) }
  scope :immortal, -> { where(category: 'immortal') }
  scope :ancient, -> { where(category: 'ancient') }
  scope :divine_plus, -> { where(rank_medal: ['divine', 'immortal']) }
  scope :admins, -> { where(role: 'admin') }
  scope :players, -> { where(role: 'player') }

  def positions
    JSON.parse(read_attribute(:positions) || '[]')
  end

  def positions=(value)
    write_attribute(:positions, value.to_json)
  end

  def can_join_ancient_list?
    true
  end

  def can_join_immortal_list?
    ['divine', 'immortal'].include?(rank_medal)
  end

  def plays_position?(position)
    positions.include?(position.to_s.upcase)
  end

  def display_rank
    if rank_medal == 'immortal'
      "Immortal ##{rank_stars}"
    else
      "#{rank_medal.humanize} #{rank_stars}"
    end
  end

  def full_display_name
    "#{name} (#{nickname})"
  end

  def admin?
    role == 'admin'
  end

  def player?
    role == 'player'
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def set_category_from_rank
    self.category = if ['divine', 'immortal'].include?(rank_medal)
                      'immortal'
                    else
                      'ancient'
                    end
  end

  def set_defaults
    self.role ||= 'player'
    self.active = true if active.nil?
    self.positions = [] if positions.empty?
  end

  def positions_are_valid
    return if positions.blank?

    invalid_positions = positions - POSITIONS
    return if invalid_positions.empty?

    errors.add(:positions, "contains invalid positions: #{invalid_positions.join(', ')}")
  end

  def category_matches_rank
    expected_category = ['divine', 'immortal'].include?(rank_medal) ? 'immortal' : 'ancient'
    return if category == expected_category

    errors.add(:category, "must be #{expected_category} for #{rank_medal} rank")
  end

  def password_required?
    password_digest.blank? || password.present?
  end
end
