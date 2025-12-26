# シミュレーション結果の可視化

## 概要

`result/` ディレクトリに出力される CSV 結果を可視化するガイド。
全グラフで No Sharing、Static Division、Optimized の 3 手法を比較表示。

Lambda Sweep 機能により、異なるトラフィック負荷（lambda 値）での性能比較も可能。

---

## 環境構築（uv）

```bash
# uvをインストール（未インストールの場合）
curl -LsSf https://astral.sh/uv/install.sh | sh

# プロジェクト初期化
cd sim-rust
uv init viz --python 3.12
cd viz

# 依存関係を追加
uv add polars matplotlib
```

---

## 出力ディレクトリ構造

### Lambda Sweep 使用時

```
result/
├── lambda05/                    # lambda=0.5
│   ├── no_sharing_config.csv
│   ├── no_sharing_metrics.csv
│   ├── static_config.csv
│   ├── static_metrics.csv
│   ├── optimized_config.csv
│   └── optimized_metrics.csv
├── lambda1/                     # lambda=1.0
│   └── ...
└── lambda2/                     # lambda=2.0
    └── ...
```

> [!TIP]
> lambda 値はディレクトリ名に含まれる（例: `lambda05` = 0.5、`lambda1` = 1.0、`lambda2` = 2.0）

---

## 出力ファイル構成

シミュレーション結果は 2 つの CSV ファイルに分割して出力される。

### 設定情報 (`*_config.csv`)

| カラム                | 説明               | 単位 |
| :-------------------- | :----------------- | :--- |
| `scenario_id`         | シナリオ ID        | -    |
| `distance`            | 基地局間距離       | m    |
| `seed`                | 乱数シード         | -    |
| `method`              | 周波数共用手法     | -    |
| `macro_tx_power_dbm`  | マクロ送信電力     | dBm  |
| `macro_avg_cqi`       | マクロ平均 CQI     | -    |
| `macro_allocated_rbs` | マクロ割当 RB 数   | -    |
| `micro_tx_power_dbm`  | マイクロ送信電力   | dBm  |
| `micro_avg_cqi`       | マイクロ平均 CQI   | -    |
| `micro_allocated_rbs` | マイクロ割当 RB 数 | -    |

### 性能指標 (`*_metrics.csv`)

| カラム                 | 説明                     | 単位   |
| :--------------------- | :----------------------- | :----- |
| `scenario_id`          | シナリオ ID              | -      |
| `distance`             | 基地局間距離             | m      |
| `method`               | 周波数共用手法           | -      |
| `macro_utilization`    | マクロ需要ベース利用率   | -      |
| `macro_satisfaction`   | マクロ充足率             | -      |
| `macro_throughput`     | マクロスループット       | bps    |
| `macro_packet_loss`    | マクロパケットロス率     | 0-1    |
| `micro_utilization`    | マイクロ需要ベース利用率 | -      |
| `micro_satisfaction`   | マイクロ充足率           | -      |
| `micro_throughput`     | マイクロスループット     | bps    |
| `micro_packet_loss`    | マイクロパケットロス率   | 0-1    |
| `fairness_index`       | Jain's Fairness Index    | 0-1    |
| `frequency_efficiency` | 周波数利用効率           | bps/Hz |
| `energy_efficiency`    | エネルギー効率           | bit/J  |

---

## 推奨可視化

### 1. 距離 vs 利用率

```python
import polars as pl
import matplotlib.pyplot as plt

static = pl.read_csv('../result/statics_metrics.csv')
opt = pl.read_csv('../result/optimized_metrics.csv')

s = static.group_by('distance').agg(pl.col('micro_utilization').mean()).sort('distance')
o = opt.group_by('distance').agg(pl.col('micro_utilization').mean()).sort('distance')

plt.figure(figsize=(10, 6))
plt.plot(s['distance'], s['micro_utilization'], 'o-', label='Static')
plt.plot(o['distance'], o['micro_utilization'], 's-', label='Optimized')
plt.xlabel('Inter-BS Distance [m]')
plt.ylabel('Micro Utilization')
plt.title('Resource Utilization vs Distance')
plt.legend()
plt.grid(True)
plt.savefig('utilization_vs_distance.png', dpi=150)
```

---

### 2. 距離 vs トラフィック充足率

```python
s = static.group_by('distance').agg(pl.col('micro_satisfaction').mean()).sort('distance')
o = opt.group_by('distance').agg(pl.col('micro_satisfaction').mean()).sort('distance')

plt.figure(figsize=(10, 6))
plt.plot(s['distance'], s['micro_satisfaction'], 'o-', label='Static')
plt.plot(o['distance'], o['micro_satisfaction'], 's-', label='Optimized')
plt.xlabel('Inter-BS Distance [m]')
plt.ylabel('Micro Satisfaction')
plt.title('Traffic Satisfaction vs Distance')
plt.legend()
plt.grid(True)
plt.savefig('satisfaction_vs_distance.png', dpi=150)
```

---

### 3. 距離 vs Fairness Index

```python
s = static.group_by('distance').agg(pl.col('fairness_index').mean()).sort('distance')
o = opt.group_by('distance').agg(pl.col('fairness_index').mean()).sort('distance')

plt.figure(figsize=(10, 6))
plt.plot(s['distance'], s['fairness_index'], 'o-', label='Static')
plt.plot(o['distance'], o['fairness_index'], 's-', label='Optimized')
plt.xlabel('Inter-BS Distance [m]')
plt.ylabel("Jain's Fairness Index")
plt.ylim(0.5, 1.05)
plt.title('Fairness Index vs Distance')
plt.legend()
plt.grid(True)
plt.savefig('fairness_vs_distance.png', dpi=150)
```

---

### 4. 距離 vs 周波数利用効率

```python
s = static.group_by('distance').agg(pl.col('frequency_efficiency').mean()).sort('distance')
o = opt.group_by('distance').agg(pl.col('frequency_efficiency').mean()).sort('distance')

plt.figure(figsize=(10, 6))
plt.plot(s['distance'], s['frequency_efficiency'], 'o-', label='Static')
plt.plot(o['distance'], o['frequency_efficiency'], 's-', label='Optimized')
plt.xlabel('Inter-BS Distance [m]')
plt.ylabel('Frequency Efficiency [bps/Hz]')
plt.title('Frequency Efficiency vs Distance')
plt.legend()
plt.grid(True)
plt.savefig('frequency_efficiency_vs_distance.png', dpi=150)
```

---

### 5. 距離 vs エネルギー効率

```python
s = static.group_by('distance').agg(pl.col('energy_efficiency').mean()).sort('distance')
o = opt.group_by('distance').agg(pl.col('energy_efficiency').mean()).sort('distance')

plt.figure(figsize=(10, 6))
plt.plot(s['distance'], s['energy_efficiency'] / 1000, 'o-', label='Static')
plt.plot(o['distance'], o['energy_efficiency'] / 1000, 's-', label='Optimized')
plt.xlabel('Inter-BS Distance [m]')
plt.ylabel('Energy Efficiency [kbit/J]')
plt.title('Energy Efficiency vs Distance')
plt.legend()
plt.grid(True)
plt.savefig('energy_efficiency_vs_distance.png', dpi=150)
```

---

### 6. 距離 vs パケットロス率

マクロセルとマイクロセルのパケットロス率を距離ごとに比較。

```python
# マクロセルパケットロス率
s_macro = static.group_by('distance').agg(pl.col('macro_packet_loss').mean()).sort('distance')
o_macro = opt.group_by('distance').agg(pl.col('macro_packet_loss').mean()).sort('distance')
n_macro = nosharing.group_by('distance').agg(pl.col('macro_packet_loss').mean()).sort('distance')

plt.figure(figsize=(10, 6))
plt.plot(s_macro['distance'], s_macro['macro_packet_loss'] * 100, 'o-', label='Static')
plt.plot(o_macro['distance'], o_macro['macro_packet_loss'] * 100, 's-', label='Optimized')
plt.plot(n_macro['distance'], n_macro['macro_packet_loss'] * 100, '^-', label='No Sharing')
plt.xlabel('Inter-BS Distance [m]')
plt.ylabel('Macro Packet Loss Rate [%]')
plt.title('Macro Cell Packet Loss Rate vs Distance')
plt.legend()
plt.grid(True)
plt.savefig('macro_packet_loss_vs_distance.png', dpi=150)
```

```python
# マイクロセルパケットロス率
s_micro = static.group_by('distance').agg(pl.col('micro_packet_loss').mean()).sort('distance')
o_micro = opt.group_by('distance').agg(pl.col('micro_packet_loss').mean()).sort('distance')
n_micro = nosharing.group_by('distance').agg(pl.col('micro_packet_loss').mean()).sort('distance')

plt.figure(figsize=(10, 6))
plt.plot(s_micro['distance'], s_micro['micro_packet_loss'] * 100, 'o-', label='Static')
plt.plot(o_micro['distance'], o_micro['micro_packet_loss'] * 100, 's-', label='Optimized')
plt.plot(n_micro['distance'], n_micro['micro_packet_loss'] * 100, '^-', label='No Sharing')
plt.xlabel('Inter-BS Distance [m]')
plt.ylabel('Micro Packet Loss Rate [%]')
plt.title('Micro Cell Packet Loss Rate vs Distance')
plt.legend()
plt.grid(True)
plt.savefig('micro_packet_loss_vs_distance.png', dpi=150)
```

---

### 7. 箱ひげ図（統計分布比較）

```python
distances = sorted(static['distance'].unique().to_list())
s_data = [static.filter(pl.col('distance') == d)['micro_utilization'].to_list() for d in distances]
o_data = [opt.filter(pl.col('distance') == d)['micro_utilization'].to_list() for d in distances]

fig, axes = plt.subplots(1, 2, figsize=(16, 6), sharey=True)
axes[0].boxplot(s_data, tick_labels=distances)
axes[0].set_title('Static Division')
axes[0].set_xlabel('Distance [m]')
axes[0].set_ylabel('Micro Utilization')
axes[0].tick_params(axis='x', rotation=45)

axes[1].boxplot(o_data, tick_labels=distances)
axes[1].set_title('Optimized')
axes[1].set_xlabel('Distance [m]')
axes[1].tick_params(axis='x', rotation=45)

plt.tight_layout()
plt.savefig('utilization_boxplot.png', dpi=150)
```

---

## Lambda Sweep 可視化

複数の lambda 値でシミュレーションした結果を比較するグラフ生成例。

### 8. Lambda vs 性能指標（距離固定）

特定の距離で lambda を変化させた場合の性能比較。

```python
import polars as pl
import matplotlib.pyplot as plt
from pathlib import Path

RESULT_DIR = Path('../result')
LAMBDAS = [0.5, 1.0, 2.0]
LAMBDA_DIRS = ['lambda05', 'lambda1', 'lambda2']
TARGET_DISTANCE = 100  # 比較対象の距離 [m]

def load_lambda_data(lambda_dir: str) -> pl.DataFrame | None:
    """lambda ディレクトリからデータを読み込む"""
    path = RESULT_DIR / lambda_dir / 'static_metrics.csv'
    if path.exists():
        return pl.read_csv(path)
    return None

# データ収集
results = {'lambda': [], 'micro_satisfaction': [], 'fairness_index': []}
for lam, lam_dir in zip(LAMBDAS, LAMBDA_DIRS):
    df = load_lambda_data(lam_dir)
    if df is not None:
        filtered = df.filter(pl.col('distance') == TARGET_DISTANCE)
        results['lambda'].append(lam)
        results['micro_satisfaction'].append(filtered['micro_satisfaction'].mean())
        results['fairness_index'].append(filtered['fairness_index'].mean())

# グラフ生成
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

ax1.plot(results['lambda'], results['micro_satisfaction'], 'o-', color='blue')
ax1.set_xlabel('Lambda [files/s/UE]')
ax1.set_ylabel('Micro Satisfaction')
ax1.set_title(f'Traffic Satisfaction (d={TARGET_DISTANCE}m)')
ax1.grid(True)

ax2.plot(results['lambda'], results['fairness_index'], 's-', color='green')
ax2.set_xlabel('Lambda [files/s/UE]')
ax2.set_ylabel("Jain's Fairness Index")
ax2.set_title(f'Fairness Index (d={TARGET_DISTANCE}m)')
ax2.set_ylim(0.5, 1.05)
ax2.grid(True)

plt.tight_layout()
plt.savefig('lambda_sweep_performance.png', dpi=150)
```

### 9. 距離 × Lambda ヒートマップ

距離と lambda の 2 次元で性能を可視化。

```python
import numpy as np

distances = [50, 100, 150, 200, 250]
lambdas = [0.5, 1.0, 2.0]
lambda_dirs = ['lambda05', 'lambda1', 'lambda2']

# ヒートマップ用データ収集
satisfaction_matrix = []
for lam_dir in lambda_dirs:
    df = load_lambda_data(lam_dir)
    if df is not None:
        row = []
        for d in distances:
            val = df.filter(pl.col('distance') == d)['micro_satisfaction'].mean()
            row.append(val)
        satisfaction_matrix.append(row)

# ヒートマップ描画
fig, ax = plt.subplots(figsize=(10, 6))
im = ax.imshow(satisfaction_matrix, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1)

ax.set_xticks(range(len(distances)))
ax.set_xticklabels(distances)
ax.set_yticks(range(len(lambdas)))
ax.set_yticklabels(lambdas)
ax.set_xlabel('Distance [m]')
ax.set_ylabel('Lambda [files/s/UE]')
ax.set_title('Micro Satisfaction Heatmap')

plt.colorbar(im, label='Satisfaction')
plt.tight_layout()
plt.savefig('satisfaction_heatmap.png', dpi=150)
```

---

## クイックスタート

```bash
# 環境セットアップ
cd sim-rust/viz

# 通常実行（result/ 直下のファイルを使用）
uv run python plot.py

# Lambda Sweep 結果を可視化（各 lambda ディレクトリを処理）
uv run python plot.py --lambda-sweep
```

> [!TIP] > `--lambda-sweep` オプションは `result/lambda*/` ディレクトリを自動検出して処理します。
