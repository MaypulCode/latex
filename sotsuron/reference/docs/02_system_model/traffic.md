# トラフィックモデル

## eMBB トラフィックモデル仕様 (FTP Model 3)

本シミュレーションでは、5G NR eMBB (Enhanced Mobile Broadband) のトラフィック評価として、**Non-Full Buffer モデル**である **FTP Model 3** を採用する。

本モデルは、**3GPP TR 36.814 (Annex A.2.1.3)** で定義され、5G NR の評価仕様書である **3GPP TR 38.802** においても eMBB のユーザー体験評価用として参照されている事実上の標準モデルである。

---

## パケット到着モデル

ファイル（データ塊）の発生は **ポアソン過程 (Poisson Point Process)** に従う。すなわち、ファイル発生間隔は指数分布に従う。

$$T_{inter} \sim \text{Exponential}(\lambda)$$

| 記号      | パラメータ名 | 設定値         | 備考                                 |
| :-------- | :----------- | :------------- | :----------------------------------- |
| $\lambda$ | 平均到着率   | 可変 [files/s] | トラフィック負荷を制御するパラメータ |

> [!NOTE]
> λ はシステム容量に対する負荷率を制御するために調整可能。
>
> **トラフィック負荷（1 セルあたり）** = λ × 平均ファイルサイズ × UE 数
>
> - λ=1.0, 10 UE: 1.0 × 16 Mbps × 10 = **160 Mbps/セル**
> - λ=2.0, 10 UE: 2.0 × 16 Mbps × 10 = **320 Mbps/セル**
>
> システム容量（約 **546 Mbps**）に対し、lambda=1.0-2.0 が推奨範囲。
> `sweep` コマンドで複数の lambda 値を一括評価可能。

---

## データサイズモデル

各ファイルサイズ $S$ は、**切断対数正規分布 (Truncated Lognormal Distribution)** に従う。

確率密度関数 (PDF):

$$f(x) = \frac{1}{\sqrt{2\pi}\sigma x} \exp\left(-\frac{(\ln x - \mu)^2}{2\sigma^2}\right), \quad x \ge S_{min}$$

パラメータ設定 (TR 36.814 ベース):

| 記号      | パラメータ名       | 3GPP 標準値 | シミュレータ設定値    |
| :-------- | :----------------- | :---------- | :-------------------- |
| $E[S]$    | 平均ファイルサイズ | 2 MBytes    | $16 \times 10^6$ bits |
| $\sigma$  | 対数標準偏差       | 0.35        | 0.35                  |
| $\mu$     | 対数平均           | 14.45       | 16.52 (bits 換算)     |
| $S_{min}$ | 最小サイズ         | -           | 800 bits (100 bytes)  |
| $S_{max}$ | 最大サイズ         | 5 MBytes    | $40 \times 10^6$ bits |

> [!NOTE] > $\mu$ は平均ファイルサイズ $E[S]$ と $\sigma$ から以下の式で導出される。
> $$\mu = \ln(E[S]) - \frac{\sigma^2}{2}$$

---

## QoS 要件と許容遅延

eMBB トラフィックとして、3GPP TS 23.501 の 5QI 定義に基づく遅延制約を設ける。

| 5QI | Resource Type | Priority | PDB (Packet Delay Budget) | Service Example                       |
| :-- | :------------ | :------- | :------------------------ | :------------------------------------ |
| 6   | Non-GBR       | 60       | **300 ms**                | Video (Buffered Streaming), TCP-based |

### ドロップ判定ロジック

各ファイル（パケット群）には到着時刻に基づいたデッドラインが設定される。

$$t_{\text{deadline}} = t_{\text{arrival}} + \text{PDB}$$

シミュレーション内の現在時刻 $t_{current}$ がデッドラインを超過した場合、該当データは破棄（ドロップ）され、パケットロスとして計上される。

$$\text{drop} = \begin{cases} \text{true} & \text{if } t_{\text{current}} > t_{\text{deadline}} \\ \text{false} & \text{otherwise} \end{cases}$$

> [!IMPORTANT]
> 許容遅延時間は `config.toml` の `[traffic].delay_budget_ms` で設定される。

### パケットロス率

ドロップされたパケットに基づいてパケットロス率を算出する。

$$PLR_{cell} = \frac{N_{drop}^{cell}}{N_{total}^{cell}}$$

| 記号               | 説明                     |
| :----------------- | :----------------------- |
| $N_{drop}^{cell}$  | ドロップされたパケット数 |
| $N_{total}^{cell}$ | 到着した全パケット数     |

> [!NOTE]
> パケットロス率は評価指標として出力され、マクロセル・マイクロセルごとに可視化される。
> 詳細は [評価指標](../04_algorithms/metrics.md#8-パケットロス率) を参照。

---

## トラフィック生成アルゴリズム

```text
Initialize:
    t_current = 0
    lambda = (Target Load) / (Mean File Size)

Loop while t_current < simulation_duration:
    // 1. 次の到着時間を決定 (Exponential Distribution)
    inter_arrival_time ~ Exponential(1 / lambda)
    t_current = t_current + inter_arrival_time

    // 2. ファイルサイズを決定 (Lognormal Distribution)
    //    Mean=2MB, Sigma=0.35
    file_size_bits ~ LogNormal(mu=16.52, sigma=0.35)

    //    クリッピング
    file_size_bits = clip(file_size_bits, min_size, max_size)

    // 3. デッドライン設定
    deadline = t_current + 0.300 // 300ms

    // 4. パケット生成キューへ追加
    generate_packet(arrival_time=t_current, size=file_size_bits, deadline=deadline)
End Loop
```

---

## Rust 実装

### ディレクトリ構成

```
src/traffic/
├── mod.rs           # モジュールルート
└── embb.rs          # eMBBトラフィック生成
```

### トラフィック生成トレイト

```rust
/// トラフィック生成トレイト
pub trait TrafficGenerator {
    /// 指定ステップのパケットを生成
    fn generate(&mut self, step: u64) -> Vec<Packet>;
}
```

### eMBB トラフィック生成器

```rust
pub struct EmbbTrafficGenerator {
    lambda: f64,              // 到着率 [packets/s]
    lognormal_mu: f64,        // 対数正規分布 μ
    lognormal_sigma: f64,     // 対数正規分布 σ
    min_size_bits: u64,       // 最小データ量
    max_size_bits: u64,       // 最大データ量
    delay_budget_ms: f64,     // 許容遅延 [ms]
    rng: StdRng,
}

impl EmbbTrafficGenerator {
    pub fn new(config: &TrafficConfig, seed: u64) -> Self;
}

impl TrafficGenerator for EmbbTrafficGenerator {
    fn generate(&mut self, step: u64) -> Vec<Packet> {
        // ポアソン過程でパケット到着を生成
        // 対数正規分布でデータ量を決定
        // deadline_time_s = arrival_time_s + delay_budget_ms / 1000.0
    }
}
```

---

## 設定例

```toml
[traffic]
lambda = 10.0               # 平均到着率 [files/s] (負荷に応じて調整)
lognormal_mu = 16.52        # 対数正規分布 μ (mean=16Mbits基準)
lognormal_sigma = 0.35      # 対数正規分布 σ (3GPP標準)
min_size_bits = 800         # 最小データサイズ [bits] (100 bytes)
max_size_bits = 40000000    # 最大データサイズ [bits] (5 MB)
delay_budget_ms = 300.0     # 許容遅延 [ms] (5QI 6基準)
```
