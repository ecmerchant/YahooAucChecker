Delayed::Worker.destroy_failed_jobs = false
# 実行失敗したジョブを削除：falseだとfailed_atに時間が入ってDBに残る
Delayed::Worker.sleep_delay = 2 # スリープタイム
Delayed::Worker.max_attempts = 0 # 最大実行回数
Delayed::Worker.max_run_time = 5.minute # 最長実行時間
Delayed::Worker.delay_jobs = !Rails.env.test? # テスト環境ではdelayed_jobをうごかさない
