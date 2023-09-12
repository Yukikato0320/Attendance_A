module AttendancesHelper
  # Attendanceオブジェクトの状態を判定して返すメソッド
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      # 出勤していない場合
      return '出勤' if attendance.started_at.nil?
      # 退勤していない場合
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end

  # Attendanceオブジェクトの状態を判定して返すメソッド
  def attendance_state?(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価する
    Date.current == attendance.worked_on
  end

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返すメソッド
  def working_times(start, finish)
    # 2fとはfloatNumber、小数点のこと。
    format("%.2f", (((finish - start) / 60) / 60.0))
  end

  # 出勤時間と退勤時間を受け取り、翌日までの在社時間を計算して返すメソッド
  def working_times_next_day(start, finish, next_day)
    if next_day == true
      format('%.2f', ((finish.hour - start.hour) + (finish.min - start.min) / 60.0) + 24)
    else
      format('%.2f', ((finish.hour - start.hour) + (finish.min - start.min) / 60.0))
    end
  end

  # 時刻を2桁の文字列でフォーマットするメソッド
  def format_hour(time)
    # 2d == two digits 2桁
    format('%.2d', time.hour)
  end

  # 分を2桁の文字列でフォーマットするメソッド
  def format_min(time)
    # 2d == two digits 2桁
    format('%.2d', time.min)
  end
end