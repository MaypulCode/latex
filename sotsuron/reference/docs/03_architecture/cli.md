# CLI インターフェース

## コマンド一覧

| コマンド               | 説明                   |
| :--------------------- | :--------------------- |
| `local5g-sim generate` | テストデータを生成     |
| `local5g-sim simulate` | シミュレーションを実行 |

---

## generate コマンド

テストデータを生成してファイルに保存。

### 使用法

```bash
local5g-sim generate -c <config> -o <output> [--lambda <value>]
```

### オプション

| オプション | 短縮 | 説明                            | デフォルト            |
| :--------- | :--- | :------------------------------ | :-------------------- |
| `--config` | `-c` | 設定ファイルパス                | `config/default.toml` |
| `--output` | `-o` | 出力ディレクトリ                | 必須                  |
| `--lambda` | `-l` | トラフィック到着率 [files/s/UE] | config.toml の値      |

### 例

```bash
# 本番設定で生成（default.tomlが使用される）
local5g-sim generate -o dataset/

# テスト用設定で生成
local5g-sim generate -c config/test.toml -o dataset/

# 特定のlambda値でデータセット生成
local5g-sim generate -o dataset_lambda_1.0/ --lambda 1.0
```

---

## simulate コマンド

生成済みデータを読み込んでシミュレーション実行。

### 使用法

```bash
local5g-sim simulate -d <dataset> -o <output> [--method <method>] [-c <config>]
```

### オプション

| オプション  | 短縮 | 説明                     | デフォルト            |
| :---------- | :--- | :----------------------- | :-------------------- |
| `--dataset` | `-d` | データセットディレクトリ | 必須                  |
| `--output`  | `-o` | 結果出力パス（CSV）      | 必須                  |
| `--method`  |      | 周波数共用手法           | `static`              |
| `--config`  | `-c` | 設定ファイルパス         | `config/default.toml` |

### 周波数共用手法

| 値          | 説明                     |
| :---------- | :----------------------- |
| `static`    | 静的分割（137/136 RB）   |
| `optimized` | 二段階最適化（提案手法） |

### 例

```bash
# 静的分割で実行
local5g-sim simulate -d dataset/ -o results/static.csv --method static

# 提案手法で実行
local5g-sim simulate -d dataset/ -o results/optimized.csv --method optimized
```

---

## 出力例

```
2050シナリオのシミュレーションを実行します...

[1/41] 距離 50m のシナリオを処理中...
  50シナリオを読み込み完了、シミュレーション実行中...
完了 [00:00:05] [████████████████████████████████████████] 50/50 (100%)

=== シミュレーション結果サマリ ===
手法: Static Division (137/136)
平均公平性指数 (Jain):    0.9993
平均周波数効率 [bps/Hz]:  0.4890
平均エネルギー効率 [b/J]: 220272.46

シミュレーション完了: 2050シナリオ
結果出力先: "results/static.csv"
```

---

## Lambda Sweep 評価ワークフロー

lambda（トラフィック到着率）を変化させてシステム性能を評価するための手順。

### ワークフロー

```bash
# 1. 各lambda値でデータセット生成
local5g-sim generate -o dataset_lambda_0.5/ --lambda 0.5
local5g-sim generate -o dataset_lambda_1.0/ --lambda 1.0
local5g-sim generate -o dataset_lambda_2.0/ --lambda 2.0

# 2. 各データセットでシミュレーション実行
local5g-sim simulate -d dataset_lambda_0.5/ -o result/lambda_0.5 --method static
local5g-sim simulate -d dataset_lambda_1.0/ -o result/lambda_1.0 --method static
local5g-sim simulate -d dataset_lambda_2.0/ -o result/lambda_2.0 --method static
```

### lambda 値の選択指針

| lambda 値 | トラフィック負荷         | 想定される用途             |
| :-------- | :----------------------- | :------------------------- |
| 0.5       | 軽負荷（80 Mbps/セル）   | 低遅延・高信頼性評価       |
| 1.0       | 中負荷（160 Mbps/セル）  | 標準評価                   |
| 2.0       | 高負荷（320 Mbps/セル）  | 容量限界評価               |
| 5.0+      | 過負荷（800 Mbps/セル+） | ストレステスト・飽和点評価 |

> [!TIP]
> システム容量（約 546 Mbps）に対し、lambda=1.0-2.0 の範囲で現実的な評価が可能。
> データセット生成時に履歴（history.parquet）にも lambda が反映される。
