class Attendance < ApplicationRecord
  belongs_to :user
  #勤怠時間が存在しないとダメにする。
  validates :worked_on, presence: true
  #備考欄はMAX50文字にして、51文字以上はダメにする。
  validates :note, length: { maximum: 50 }
  #出勤時間がない場合、退勤時間は無効で、出勤時間を求めるエラーメッセージを出させる。→退勤時間だけだとダメにする。
  validate :finished_at_is_invalid_without_a_started_at
  #出勤・退勤時間どちらも存在する場合、出勤時間より早い退勤時間は無効。→辻褄が合わないとダメにする。
  validate :started_at_than_finished_at_fast_if_invalid
  #出勤時間と退勤時間両方、+上長を選択・入力しないと無効。
  validate :all_items_must_be_present_edit_one_month

# もし出勤時間が、空なら、退勤時間は申請(登録)できない。
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

# もし退勤時間が、出勤時間より早ければ、無効にする。
  def started_at_than_finished_at_fast_if_invalid
    if next_day_working_hours == false && (started_at.present? && finished_at.present?) && (started_at > finished_at)
      errors.add(:started_at, "より早い退勤時間は無効です")
    end
    return unless next_day_working_hours == false
    return unless started_at_edited.present? && finished_at_edited.present?

    errors.add(:started_at_edited, 'より早い退勤時間は無効です') if started_at_edited > finished_at_edited
  end


# 全ての記入がなければ、申請(登録)できない。
  def all_items_must_be_present_edit_one_month
    if (started_at_edited.present? && finished_at_edited.present?) && selector_working_hours_request.blank?
      errors.add(:started_at_edited, '出社時間と退社時間の両方を入力して、上長を選択してください')
    end
    if (started_at_edited.present? && finished_at_edited.blank?) && selector_working_hours_request.blank?
      errors.add(:started_at_edited, '出社時間と退社時間の両方を入力して、上長を選択してください')
    end
    if (started_at_edited.blank? && finished_at_edited.present?) && selector_working_hours_request.blank?
      errors.add(:started_at_edited, '出社時間と退社時間の両方を入力して、上長を選択してください')
    end
    if (started_at_edited.present? && finished_at_edited.blank?) && selector_working_hours_request.present?
      errors.add(:started_at_edited, '出社時間と退社時間の両方を入力して、上長を選択してください')
    end
    return unless (started_at_edited.blank? && finished_at_edited.present?) && selector_working_hours_request.present?

    errors.add(:started_at_edited, '出社時間と退社時間の両方を入力して、上長を選択してください')
  end

end