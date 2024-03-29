class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..30 }, allow_blank: true
  validates :affiliation, length: { in: 2..50 }, allow_blank: true
  validates :basic_time, presence: true
  validates :work_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end

  # csvインポート
  def self.import(file)
    #CSVファイルの各行を処理
    CSV.foreach(file.path, headers: true) do |row|
      #'id'カラムの値を使って既存のユーザーを検索する。見つからなければ新しいユーザーを作成/特定の属性が意図せず更新されることを防ぐ
      user = find_by(id: row['id']) || new
      #CSV行のデータから更新可能な属性のみを選んでユーザーオブジェクトに割り当てる
      user.attributes = row.to_hash.slice(*updatable_attributes)
      #バリデーションを無効にし、ユーザーオブジェクトをデータベースに保存/通常のバリデーションルールを通過せずともデータ保存される
      user.save!(validation: false)
    end
  end

  # インポートするカラム
  def self.updatable_attributes
    # ユーザーオブジェクトの属性のうち、CSVファイルから更新可能なものを指定する
    %w[name email affiliation employee_number uid basic_work_time designated_work_start_time
      designated_work_end_time superior admin password]
  end

  def self.search(search)
    if search
      where(['name LIKE ?' , "%#{search}%"])
    else
      all
    end
  end
end