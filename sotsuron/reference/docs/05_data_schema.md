# データ構造（入出力スキーマ）

## 入力データセット構成

```
dataset/
├── config.toml                    # データセット生成時の設定
├── summary.csv                    # 全シナリオのサマリ
└── scenario_{distance}_{seed}/    # 各シナリオのディレクトリ
    ├── metadata.json              # シナリオメタデータ
    ├── traffic.parquet            # トラフィックログ
    ├── channel.parquet            # チャネル状態
    ├── environment.parquet        # 環境情報（UE配置）
    ├── history.parquet            # 過去履歴メトリクス（Static基準）
    └── observation.parquet        # 基地局観測データ（提案手法用）
```

> [!IMPORTANT] > `history.parquet` はデータセット生成時に Static Division でシミュレーションを実行し、
> 各ステップの利用率・充足率等を記録したファイルです。
> Optimized Sharing はこの履歴を参照して RB 割当を最適化します。

---

## ファイル形式

### metadata.json

```json
{
  "distance": 100.0,
  "seed": 42,
  "simulation_time_s": 60.0,
  "num_macro_ue": 10,
  "num_micro_ue": 10,
  "total_rbs": 273,
  "center_freq_ghz": 4.85,
  "macro_tx_power_dbm": 41.0,
  "micro_tx_power_dbm": 7.0,
  "tdd_pattern": "DU"
}
```

---

### traffic.parquet

| カラム            | 型       | 説明                |
| :---------------- | :------- | :------------------ |
| `step`            | `u64`    | タイムステップ      |
| `ue_id`           | `u32`    | UE ID               |
| `cell_type`       | `string` | `macro` / `micro`   |
| `packet_id`       | `u64`    | パケット ID         |
| `arrival_time_s`  | `f64`    | 到着時刻 [s]        |
| `data_size_bits`  | `u32`    | データサイズ [bits] |
| `deadline_time_s` | `f64`    | 送信期限時刻 [s]    |

---

### channel.parquet

静止 UE モデルのため、各 UE につき 1 レコードのみ。

| カラム        | 型       | 説明                      |
| :------------ | :------- | :------------------------ |
| `ue_id`       | `u32`    | UE ID                     |
| `cell_type`   | `string` | `macro` / `micro`         |
| `distance_m`  | `f64`    | 接続先 gNB からの距離 [m] |
| `pathloss_db` | `f64`    | パスロス [dB]             |
| `sinr_db`     | `f64`    | SINR [dB]（基準送信電力） |
| `cqi`         | `u8`     | CQI (1-15)                |

---

### environment.parquet

| カラム              | 型       | 説明                        |
| :------------------ | :------- | :-------------------------- |
| `ue_id`             | `u32`    | UE ID                       |
| `cell_type`         | `string` | `macro` / `micro`           |
| `position_x`        | `f64`    | UE X 座標 [m]               |
| `position_y`        | `f64`    | UE Y 座標 [m]               |
| `distance_to_macro` | `f64`    | マクロ gNB からの距離 [m]   |
| `distance_to_micro` | `f64`    | マイクロ gNB からの距離 [m] |

---

### history.parquet

Static Division シミュレーション結果を記録。Optimized Sharing の入力として使用。

| カラム                | 型    | 説明                           |
| :-------------------- | :---- | :----------------------------- |
| `step`                | `u64` | タイムステップ                 |
| `macro_allocated_rbs` | `u32` | マクロセル割当 RB 数           |
| `micro_allocated_rbs` | `u32` | マイクロセル割当 RB 数         |
| `macro_avg_cqi`       | `f64` | マクロセル平均 CQI             |
| `micro_avg_cqi`       | `f64` | マイクロセル平均 CQI           |
| `macro_tx_power_dbm`  | `f64` | マクロセル送信電力 [dBm]       |
| `micro_tx_power_dbm`  | `f64` | マイクロセル送信電力 [dBm]     |
| `macro_utilization`   | `f64` | マクロセル RB 使用率           |
| `micro_utilization`   | `f64` | マイクロセル RB 使用率         |
| `macro_satisfaction`  | `f64` | マクロセル充足率               |
| `micro_satisfaction`  | `f64` | マイクロセル充足率             |
| `macro_throughput`    | `f64` | マクロセルスループット [bps]   |
| `micro_throughput`    | `f64` | マイクロセルスループット [bps] |

---

### observation.parquet

観測ベース多目的最適化（提案手法）の入力として使用する基地局観測データ。

> [!IMPORTANT]
> このファイルは基地局側で取得可能な観測値のみを含みます。
> 詳細は [多目的最適化アルゴリズム](./04_algorithms/multi_objective_sharing.md) を参照。

| カラム             | 型       | 記号                      | 説明                                   |
| :----------------- | :------- | :------------------------ | :------------------------------------- |
| `cell_type`        | `string` |                           | `macro` / `micro`                      |
| `throughput_bps`   | `f64`    | $R_{\mathrm{obs}}^k$      | 観測スループット (DL UE Throughput)    |
| `ingress_rate_bps` | `f64`    | $\lambda^k$               | 到来量 (Ingress data at PDCP) [bps]    |
| `avg_delay_s`      | `f64`    | $\bar{D}^k$               | 観測された平均遅延 [s]                 |
| `drop_rate`        | `f64`    | $P_{\mathrm{out}}^k$      | パケットドロップ率 (RLC SDU drop rate) |
| `sinr_linear`      | `f64`    | $\gamma_{\mathrm{obs}}^k$ | CQI 報告に基づく観測 SINR（線形値）    |
| `tx_power_ref_w`   | `f64`    | $P_{\mathrm{t, ref}}^k$   | 観測時の送信電力 [W]                   |
| `rb_count_ref`     | `u32`    | $N_{\mathrm{RB, obs}}^k$  | 観測時の割り当て RB 数                 |

---

### summary.csv

| カラム                | 型       | 説明                               |
| :-------------------- | :------- | :--------------------------------- |
| `scenario_id`         | `string` | シナリオ識別子                     |
| `distance`            | `f64`    | 基地局間距離 [m]                   |
| `seed`                | `u64`    | 乱数シード                         |
| `avg_demand_macro`    | `f64`    | マクロセル平均要求量 [bits/slot]   |
| `avg_demand_micro`    | `f64`    | マイクロセル平均要求量 [bits/slot] |
| `avg_cqi_macro`       | `f64`    | マクロセル平均 CQI                 |
| `avg_cqi_micro`       | `f64`    | マイクロセル平均 CQI               |
| `total_packets_macro` | `u64`    | マクロセル総パケット数             |
| `total_packets_micro` | `u64`    | マイクロセル総パケット数           |

---

## 出力 CSV スキーマ

シミュレーション結果は 2 つの CSV ファイルに分割して出力される。

### 設定情報 (`*_config.csv`)

| カラム                | 型       | 説明                       |
| :-------------------- | :------- | :------------------------- |
| `scenario_id`         | `string` | シナリオ識別子             |
| `distance`            | `f64`    | 基地局間距離 [m]           |
| `seed`                | `u64`    | 乱数シード                 |
| `method`              | `string` | 周波数共用手法             |
| `macro_tx_power_dbm`  | `f64`    | マクロセル送信電力 [dBm]   |
| `macro_avg_cqi`       | `f64`    | マクロセル平均 CQI         |
| `macro_allocated_rbs` | `f64`    | マクロセル平均割当 RB 数   |
| `micro_tx_power_dbm`  | `f64`    | マイクロセル送信電力 [dBm] |
| `micro_avg_cqi`       | `f64`    | マイクロセル平均 CQI       |
| `micro_allocated_rbs` | `f64`    | マイクロセル平均割当 RB 数 |

### 性能指標 (`*_metrics.csv`)

| カラム                 | 型       | 説明                              |
| :--------------------- | :------- | :-------------------------------- |
| `scenario_id`          | `string` | シナリオ識別子                    |
| `distance`             | `f64`    | 基地局間距離 [m]                  |
| `method`               | `string` | 周波数共用手法                    |
| `macro_utilization`    | `f64`    | マクロセル RB 使用率              |
| `macro_satisfaction`   | `f64`    | マクロセルトラフィック充足率      |
| `macro_throughput`     | `f64`    | マクロセルスループット [bits/s]   |
| `micro_utilization`    | `f64`    | マイクロセル RB 使用率            |
| `micro_satisfaction`   | `f64`    | マイクロセルトラフィック充足率    |
| `micro_throughput`     | `f64`    | マイクロセルスループット [bits/s] |
| `fairness_index`       | `f64`    | Jain's Fairness Index             |
| `frequency_efficiency` | `f64`    | 周波数利用効率 [bps/Hz]           |
| `energy_efficiency`    | `f64`    | エネルギー効率 [bit/J]            |
| `macro_packet_loss`    | `f64`    | マクロセルパケットロス率          |
| `micro_packet_loss`    | `f64`    | マイクロセルパケットロス率        |

---

## 設定ファイル（config.toml）

```toml
[simulation]
simulation_time_s = 60.0
seed = 0

[network]
center_freq_ghz = 4.85
bandwidth_mhz = 100
total_rbs = 273
num_macro_ue = 10
num_micro_ue = 10
mimo_layers = 4               # MIMOレイヤー数 (SU-MIMO)

[channel]
macro_cell_radius_m = 300.0   # マクロセル半径 [m]
micro_cell_radius_m = 50.0    # マイクロセル半径 [m]
cell_edge_power_dbm = -84.6   # セル端受信電力 [dBm]
h_bs = 10.0
h_ue = 1.5
margin_db = 8.0

[traffic]
lambda = 10.0                # 平均到着率 [files/s]
lognormal_mu = 16.52         # 対数正規分布 μ
lognormal_sigma = 0.35       # 対数正規分布 σ
min_size_bits = 800          # 最小データサイズ [bits]
max_size_bits = 40000000     # 最大データサイズ [bits]
delay_budget_ms = 300.0

[monte_carlo]
min_distance_m = 50.0
max_distance_m = 250.0
step_m = 5.0
num_seeds = 50
```

---

## Rust 実装

### データセット生成器

```rust
pub struct DatasetGenerator {
    config: AppConfig,
    output_dir: PathBuf,
}

impl DatasetGenerator {
    pub fn new(config: AppConfig, output_dir: &Path) -> Self;
    pub fn generate_all_with_progress(&self, pb: &ProgressBar) -> Result<Vec<ScenarioSummary>, DatasetError>;
}
```

### データセット読込器

```rust
pub struct DatasetLoader {
    base_dir: PathBuf,
}

impl DatasetLoader {
    pub fn new(base_dir: &Path) -> Self;
    pub fn load_summaries(&self) -> Result<Vec<ScenarioSummary>, DatasetError>;
    pub fn load_scenario(&self, distance: f64, seed: u64) -> Result<ScenarioData, DatasetError>;
}
```

### 結果収集

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Metrics {
    pub frequency_efficiency: f64,
    pub fairness_index: f64,
    pub energy_efficiency: f64,
    pub macro_utilization: f64,
    pub micro_utilization: f64,
    pub macro_throughput: f64,
    pub micro_throughput: f64,
    pub macro_allocated_rbs: f64,
    pub micro_allocated_rbs: f64,
    pub macro_avg_cqi: f64,
    pub micro_avg_cqi: f64,
    pub macro_tx_power_dbm: f64,
    pub micro_tx_power_dbm: f64,
    pub macro_satisfaction: f64,
    pub micro_satisfaction: f64,
    pub macro_packet_loss: f64,
    pub micro_packet_loss: f64,
}
```
