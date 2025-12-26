# 更新履歴

本ドキュメントは、ローカル 5G リソース割り当てシミュレータ関連ドキュメントの更新履歴をまとめたものです。

---

## ドキュメント構造

| 日付       | 内容                                                                                            |
| :--------- | :---------------------------------------------------------------------------------------------- |
| 2025-12-17 | ドキュメント構造をリファクタリング。modeling.md, overview.md を 5 カテゴリ+サブファイルに分割。 |
| 2025-12-17 | design/の実装詳細を各ドキュメントに統合。design/ディレクトリを削除。                            |

### 現在の構造

```
docs/
├── README.md              # 目次
├── 01_overview.md         # 概要とスコープ
├── 02_system_model/       # システムモデル（5ファイル）
├── 03_architecture/       # アーキテクチャ（4ファイル）
├── 04_algorithms/         # アルゴリズム（4ファイル）
├── 05_data_schema.md      # データ構造
└── update.md              # 更新履歴
```

---

## ドキュメント更新履歴

| 日付       | ファイル                   | 内容                                       |
| :--------- | :------------------------- | :----------------------------------------- |
| 2025-12-16 | (旧)modeling.md            | 初版作成〜数理モデル完成                   |
| 2025-12-16 | (旧)overview.md            | 初版作成〜詳細設計完成                     |
| 2025-12-17 | 02_system_model/channel.md | MCS テーブル CQI 1 符号化率を 76→78 に修正 |
| 2025-12-17 | 04_algorithms/metrics.md   | RB 使用率の定義を送信データ量ベースに変更  |

---

## 設計ドキュメント (docs/design/)

| 日付       | ファイル          | 内容                                                                  |
| :--------- | :---------------- | :-------------------------------------------------------------------- |
| 2025-12-16 | README.md         | 初版作成。設計ドキュメント一覧と Rust ベストプラクティス。            |
| 2025-12-16 | config.md         | 設定モジュール設計書。TOML 読込、バリデーション。                     |
| 2025-12-16 | entities.md       | エンティティ設計書。Packet, UE, Gnb トレイト。                        |
| 2025-12-16 | channel.md        | チャネルモデル設計書。パスロス、CQI 変換、MCS マッピング。            |
| 2025-12-16 | traffic.md        | トラフィック設計書。eMBB FTP Model 3。                                |
| 2025-12-16 | scheduler.md      | スケジューラ設計書。Scheduler トレイト、周波数軸 RR。                 |
| 2025-12-16 | spectrum_share.md | 周波数共用設計書。静的分割、二段階最適化。                            |
| 2025-12-16 | engine.md         | シミュレーションエンジン設計書。Simulator 構造体。                    |
| 2025-12-16 | results.md        | 結果収集設計書。評価指標計算、CSV 出力。                              |
| 2025-12-16 | dataset.md        | データセット設計書。生成器、読込器、Parquet スキーマ。                |
| 2025-12-17 | channel.md        | MCS テーブル CQI 1 符号化率を 76→78 に修正。                          |
| 2025-12-17 | results.md        | SimulationResult にマクロ/マイクロセルの割当 RB 数・平均 CQI を追加。 |

---

## ソースコード (src/)

| 日付       | ファイル                        | 内容                                                                                               |
| :--------- | :------------------------------ | :------------------------------------------------------------------------------------------------- |
| 2025-12-17 | config/channel.rs               | a_hm/b_hb（アンテナ高補正パラメータ）を追加。                                                      |
| 2025-12-17 | channel/pathloss.rs             | 総務省 3 領域パスロスモデル完全実装（自由空間、拡張秦式、補間）。calculate_cell_radius 関数追加。  |
| 2025-12-17 | channel/mcs.rs                  | MCS テーブル CQI 1 符号化率を 76→78 に修正（3GPP TS 38.214 準拠）。                                |
| 2025-12-17 | channel/mod.rs                  | 新規関数・定数のエクスポート追加。                                                                 |
| 2025-12-17 | results/metrics.rs              | Metrics 構造体に macro/micro_allocated_rbs、macro/micro_avg_cqi を追加。                           |
| 2025-12-17 | engine/simulator.rs             | RB 使用率計算を送信データ量ベースに変更。calculate_average_cqi, calculate_rb_utilization 追加。    |
| 2025-12-17 | main.rs                         | CSV 出力に macro/micro_allocated_rbs、macro/micro_avg_cqi の 4 カラムを追加。                      |
| 2025-12-17 | main.rs                         | CSV 出力のヘッダーと値の順序不一致を修正（バグ修正）。                                             |
| 2025-12-17 | results/metrics.rs              | Metrics に macro/micro_avg_delay_ms（平均遅延時間）を追加。                                        |
| 2025-12-17 | engine/simulator.rs             | 遅延追跡機能を追加。SimulationStats, update_stats, calculate_final_metrics を拡張。                |
| 2025-12-17 | main.rs                         | CSV 出力に macro/micro_avg_delay_ms カラムを追加。                                                 |
| 2025-12-17 | dataset/generator.rs            | ACIR 隣接チャネル干渉モデルを実装（ACLR=45dB, ACS=33dB, ACIR=32.7dB）。                            |
| 2025-12-17 | config/channel.rs               | セル半径ベース設定に変更（macro_cell_radius_m, micro_cell_radius_m, cell_edge_power_dbm）。        |
| 2025-12-17 | channel/pathloss.rs             | calculate_tx_power_from_radius 関数を追加（セル半径 → 送信電力逆算）。                             |
| 2025-12-17 | dataset/generator.rs            | UE 配置を均一密度（√U 補正）に変更。セル半径から送信電力を自動計算。                               |
| 2025-12-17 | main.rs                         | シミュレーション並列化最適化。オンデマンド読み込み方式で OOM 回避、実行時間 33%短縮。              |
| 2025-12-17 | dataset/loader.rs               | 並列読み込み対応（rayon 導入）。                                                                   |
| 2025-12-17 | engine/simulator.rs             | RB 利用率計算を需要ベースに変更。使用 RB 数追跡を追加（バグ修正）。                                |
| 2025-12-17 | docs/metrics.md                 | RB 使用率の定義を需要ベースに更新。                                                                |
| 2025-12-17 | docs/06_visualization.md        | シミュレーション結果の可視化ガイドを新規作成。Python サンプルコード付き。                          |
| 2025-12-18 | channel/sinr.rs                 | SinrCalculator を新規作成。フル SINR 再計算（パスロス・干渉・熱雑音考慮）。                        |
| 2025-12-18 | engine/simulator.rs             | SinrCalculator を使用した動的 SINR/CQI 再計算に変更。update_all_channels() 追加。                  |
| 2025-12-18 | results/metrics.rs              | Metrics に macro/micro_satisfaction（トラフィック充足率）を追加。                                  |
| 2025-12-18 | results/metrics.rs              | Metrics に macro/micro_tx_power_dbm（送信電力）を追加。                                            |
| 2025-12-18 | engine/simulator.rs             | SimulationStats に到着トラフィック量追跡を追加。充足率計算を実装。                                 |
| 2025-12-18 | main.rs                         | CSV 出力に送信電力・充足率カラムを追加。                                                           |
| 2025-12-18 | dataset/mod.rs                  | recalculate_channel 関数を非推奨化（#[deprecated]）。                                              |
| 2025-12-18 | docs/05_data_schema.md          | history.parquet スキーマを追加（過去履歴メトリクス）。                                             |
| 2025-12-18 | docs/04_algorithms/             | optimized_sharing.md に履歴参照の説明を追加。metrics.md に充足率定義を追加。                       |
| 2025-12-18 | docs/02_system_model/           | channel.md に動的 SINR 再計算セクションと SinrCalculator ドキュメントを追加。                      |
| 2025-12-18 | dataset/schema.rs               | HistoryRecord 構造体を追加（履歴メトリクス用）。                                                   |
| 2025-12-18 | dataset/generator.rs            | generate_scenario で Static シミュレーションを実行し history.parquet を生成。                      |
| 2025-12-18 | dataset/loader.rs               | load_history, load_history_parquet メソッドを追加。                                                |
| 2025-12-18 | engine/simulator.rs             | run_with_history メソッドを追加（ステップごとの履歴収集）。                                        |
| 2025-12-18 | docs/02_system_model/           | network.md に TDD（時分割複信）セクションを追加。スロット方向判定ロジック。                        |
| 2025-12-18 | docs/04_algorithms/             | scheduling.md に TDD スロット方向セクションと SlotDirection 列挙型を追加。                         |
| 2025-12-18 | config/default.toml             | tdd_pattern 設定を追加（"DU"=交互, "DL_ONLY"=全て DL）。                                           |
| 2025-12-19 | config/default.toml             | delay_budget_ms を 10→300 に変更（3GPP TS 23.501 5QI 6 準拠）。                                    |
| 2025-12-19 | entities/packet.rs              | 時間ベースパケット管理に変更（arrival_time_s, deadline_time_s: f64）。                             |
| 2025-12-19 | dataset/schema.rs               | TrafficRecord.deadline_step (u64) → deadline_time_s (f64) に変更。                                 |
| 2025-12-19 | config/traffic.rs               | delay_budget_slots() → delay_budget_s() に変更。デフォルト値を 300ms に更新。                      |
| 2025-12-19 | traffic/embb.rs                 | 時間ベースでパケット生成（delay_budget_s: f64）。                                                  |
| 2025-12-19 | entities/ue.rs                  | drop_expired() を時間ベース (f64) に変更。                                                         |
| 2025-12-19 | dataset/generator.rs            | Parquet スキーマを deadline_time_s (f64) に更新。                                                  |
| 2025-12-19 | dataset/loader.rs               | deadline_time_s の読込に対応。                                                                     |
| 2025-12-19 | engine/simulator.rs             | 時間ベースのドロップ判定・遅延計算に変更。                                                         |
| 2025-12-19 | main.rs                         | CSV 出力を 2 ファイルに分割（_\_config.csv, _\_metrics.csv）。                                     |
| 2025-12-19 | docs/05_data_schema.md          | CSV スキーマを 2 ファイル構成に更新。                                                              |
| 2025-12-19 | viz/plot.py                     | \*\_metrics.csv 形式に対応するよう可視化スクリプトを更新。                                         |
| 2025-12-21 | docs/03_architecture/cli.md     | `generate`コマンドに`--lambda`オプションを追加。Lambda Sweep 評価ワークフローを追加。              |
| 2025-12-21 | docs/02_system_model/traffic.md | トラフィック負荷計算式と lambda 推奨範囲を追加。                                                   |
| 2025-12-21 | docs/06_visualization.md        | Lambda Sweep 可視化セクションを追加。ディレクトリ構造・サンプルコード・ヒートマップ例を追加。      |
| 2025-12-21 | viz/plot.py                     | Lambda Sweep 対応に全面改修。`--lambda-sweep` オプション、ディレクトリ自動検出、ヒートマップ追加。 |
| 2025-12-21 | main.rs (予定)                  | `generate`コマンドに`--lambda`オプションを追加。指定 lambda でトラフィック生成。                   |

---

## 設定ファイル (config/)

| 日付       | ファイル        | 内容                                                         |
| :--------- | :-------------- | :----------------------------------------------------------- |
| 2025-12-17 | default.toml    | 本番用設定に変更（60 秒、2050 シナリオ）。デフォルトで使用。 |
| 2025-12-17 | test.toml       | 小規模テスト用設定を新規作成（1 秒、2 シナリオ）。           |
| 2025-12-17 | production.toml | 削除（内容は default.toml に移動）。                         |
| 2025-12-19 | default.toml    | delay_budget_ms = 300.0 に更新（3GPP 5QI 6 準拠）。          |
| 2025-12-19 | default.toml    | min_size_bits/max_size_bits を 1000 倍に修正。               |
