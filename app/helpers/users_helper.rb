module UsersHelper

  # 勤怠基本情報を指定のフォーマットで返します。
  #/f=float/実数を扱うことができるデータ型。 ここで扱われる実数は、整数型の値と比べ、値の桁数が多く小数も扱えるような数値。
  # ※ %.2f = 小数点以下2桁まで表示することを意味
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
end