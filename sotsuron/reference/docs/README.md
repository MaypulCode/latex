# ドキュメント

本ディレクトリには、ローカル 5G リソース割り当てシミュレータのドキュメントを格納しています。

---

## ドキュメント構成

### 1. 概要

| ファイル                           | 内容                                 |
| :--------------------------------- | :----------------------------------- |
| [01_overview.md](./01_overview.md) | プロジェクト概要、スコープ、用語定義 |

---

### 2. システムモデル

シミュレーションで使用する数理モデルとパラメータ定義。

| ファイル                                                 | 内容                                       |
| :------------------------------------------------------- | :----------------------------------------- |
| [network.md](./02_system_model/network.md)               | ネットワーク構成（gNB 配置、UE 数）        |
| [time_frequency.md](./02_system_model/time_frequency.md) | 時間・周波数パラメータ                     |
| [channel.md](./02_system_model/channel.md)               | チャネルモデル（パスロス、SINR、CQI、MCS） |
| [traffic.md](./02_system_model/traffic.md)               | トラフィックモデル（eMBB FTP Model 3）     |
| [simulation.md](./02_system_model/simulation.md)         | シミュレーション設定（モンテカルロ）       |

---

### 3. アーキテクチャ

シミュレータのソフトウェア設計。

| ファイル                                                   | 内容                       |
| :--------------------------------------------------------- | :------------------------- |
| [execution_model.md](./03_architecture/execution_model.md) | 二段階実行モデル           |
| [modules.md](./03_architecture/modules.md)                 | モジュール構成と依存関係   |
| [dataflow.md](./03_architecture/dataflow.md)               | データフローと処理サイクル |
| [parallelization.md](./03_architecture/parallelization.md) | 並列処理アーキテクチャ     |
| [cli.md](./03_architecture/cli.md)                         | CLI インターフェース       |

---

### 4. アルゴリズム

周波数共用とスケジューリングのアルゴリズム定義。

| ファイル                                                                 | 内容                                   |
| :----------------------------------------------------------------------- | :------------------------------------- |
| [no_sharing.md](./04_algorithms/no_sharing.md)                           | 周波数分割なし（比較手法）             |
| [static_division.md](./04_algorithms/static_division.md)                 | 静的周波数分割（比較手法）             |
| [optimized_sharing.md](./04_algorithms/optimized_sharing.md)             | 二段階最適化（従来手法）               |
| [multi_objective_sharing.md](./04_algorithms/multi_objective_sharing.md) | 観測ベース多目的最適化（提案手法）     |
| [scheduling.md](./04_algorithms/scheduling.md)                           | 周波数軸ラウンドロビンスケジューリング |
| [metrics.md](./04_algorithms/metrics.md)                                 | 評価指標（効率、公平性）               |

---

### 5. データスキーマ

入力データセットと出力形式の定義。

| ファイル                                 | 内容                                                 |
| :--------------------------------------- | :--------------------------------------------------- |
| [05_data_schema.md](./05_data_schema.md) | データセット構成、Parquet/CSV スキーマ、設定ファイル |

---

### 6. 可視化

| ファイル                                     | 内容                            |
| :------------------------------------------- | :------------------------------ |
| [06_visualization.md](./06_visualization.md) | 結果の可視化（Python サンプル） |

---

### その他

| ファイル                 | 内容     |
| :----------------------- | :------- |
| [update.md](./update.md) | 更新履歴 |

---

## クイックリファレンス

### シミュレーションパラメータ

| パラメータ           | 値                 |
| :------------------- | :----------------- |
| 中心周波数           | 4.85 GHz (Sub6)    |
| 帯域幅               | 100 MHz            |
| 総 RB 数             | 273                |
| スロット長           | 0.5 ms (30kHz SCS) |
| シミュレーション時間 | 60 s               |
| 基地局間距離         | 50-250 m (5m 間隔) |
| 反復回数             | 50 回/距離         |

### コマンド

```bash
# テストデータ生成（本番設定、-c省略可）
local5g-sim generate -o dataset/

# 小規模テスト
local5g-sim generate -c config/test.toml -o test/

# シミュレーション実行
local5g-sim simulate -d dataset/ -o results.csv --method static
```
