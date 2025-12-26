# モジュール構成

## モジュール一覧

| モジュール       | 責務                                   |
| :--------------- | :------------------------------------- |
| `config`         | 設定ファイル読込・バリデーション       |
| `entities`       | UE、gNB、Packet のデータ構造           |
| `channel`        | パスロス計算、CQI 変換、MCS マッピング |
| `traffic`        | トラフィック生成                       |
| `dataset`        | データセット生成・読込                 |
| `scheduler`      | RB スケジューリング                    |
| `spectrum_share` | 周波数共用アルゴリズム                 |
| `engine`         | シミュレーション実行エンジン           |
| `results`        | 評価指標計算・結果出力                 |

---

## 依存関係

```
main.rs
    ├── config
    ├── dataset
    │     ├── channel
    │     ├── traffic
    │     └── entities
    └── engine
          ├── scheduler
          ├── spectrum_share
          ├── entities
          └── results
```

---

## モジュール詳細

### `config`

- TOML 設定ファイルの読込
- デフォルト値とバリデーション

### `entities`

- `Ue`: ユーザ端末（バッファ、CQI、位置）
- `MacroGnb` / `MicroGnb`: 基地局（送信電力、接続 UE）
- `Packet`: データパケット（サイズ、期限）

### `channel`

- パスロス計算（3 領域モデル）
- SINR→CQI 変換
- CQI→MCS→RB あたりデータ量
- `SinrCalculator`: 動的 SINR 再計算

### `scheduler`

- `Scheduler`トレイト
- `FrequencyRoundRobinScheduler`: 周波数軸 RR

### `spectrum_share`

- `SpectrumSharing`トレイト
- `StaticDivision`: 静的分割
- `OptimizedSharing`: 二段階最適化

### `engine`

- `Simulator`: シミュレーション実行
- ステップ実行とメトリクス計算

### `results`

- `Metrics`: 評価指標
- CSV 出力

---

## Rust 実装詳細

### エンティティ (`entities`)

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CellType { Macro, Micro }

#[derive(Debug, Clone)]
pub struct Packet {
    pub id: u64,
    pub arrival_step: u64,
    pub size_bits: u64,
    pub deadline: u64,
}

#[derive(Debug)]
pub struct Ue {
    pub id: u32,
    pub position: (f64, f64),
    pub buffer: VecDeque<Packet>,
    pub cqi: u8,
    pub sinr_db: f64,
    pub serving_cell: CellType,
}

/// gNB共通トレイト
pub trait Gnb {
    fn allocated_rbs(&self) -> u32;
    fn set_allocated_rbs(&mut self, rbs: u32);
    fn tx_power_dbm(&self) -> f64;
    fn connected_ue_ids(&self) -> &[u32];
}

pub struct MacroGnb { /* ... */ }
pub struct MicroGnb { /* ... */ }
```

### シミュレータ (`engine`)

```rust
pub struct Simulator {
    config: AppConfig,
    current_step: u64,
    macro_gnb: MacroGnb,
    micro_gnb: MicroGnb,
    macro_ues: HashMap<u32, Ue>,
    micro_ues: HashMap<u32, Ue>,
    scheduler: FrequencyRoundRobinScheduler,
    stats: SimulationStats,
    sinr_calculator: SinrCalculator,  // SINR再計算用
}

impl Simulator {
    pub fn from_scenario(config: AppConfig, scenario: &ScenarioData) -> Self;
    pub fn run(&mut self, scenario: &ScenarioData, summary: &ScenarioSummary, sharing: &dyn SpectrumSharing) -> SimulationResult;
}
```

### 設定 (`config`)

```rust
#[derive(Debug, Clone, Deserialize)]
#[serde(default)]
pub struct AppConfig {
    pub simulation: SimulationConfig,
    pub network: NetworkConfig,
    pub channel: ChannelConfig,
    pub traffic: TrafficConfig,
    pub monte_carlo: MonteCarloConfig,
}

impl AppConfig {
    pub fn from_file(path: impl AsRef<Path>) -> Result<Self, ConfigError>;
}
```
