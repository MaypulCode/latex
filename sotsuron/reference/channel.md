# チャネルモデル

## パスロスモデル

総務省ローカル 5G 免許申請マニュアル準拠の 3 領域パスロスモデルを使用。

### 距離領域別計算式

| 距離範囲         | モデル   | 説明                         |
| :--------------- | :------- | :--------------------------- |
| $d \leq 40$ m    | 自由空間 | 見通し環境                   |
| $40 < d < 100$ m | 補間     | 自由空間と拡張秦式の線形補間 |
| $d \geq 100$ m   | 拡張秦式 | 市街地伝搬                   |

### 自由空間パスロス（$d \leq 40$ m）

$$PL_{free}(d) = 32.4 + 20\log_{10}(f_{MHz}) + 10\log_{10}(d_{km}^2 + h_{term}) + R$$

$$h_{term} = \frac{(h_{bs} - h_{ue})^2}{10^6}$$

### 拡張秦式パスロス（$d \geq 100$ m）

$$PL_{hata}(d) = A + B\log_{10}(d_{km}) - a_{hm} - b_{hb} + R - K - S$$

### パラメータ

| 記号         | 説明             | 値     |
| :----------- | :--------------- | :----- |
| $h_{bs}$     | 基地局アンテナ高 | 10.0 m |
| $h_{ue}$     | UE アンテナ高    | 1.5 m  |
| $\alpha$     | 距離減衰係数     | 1.0    |
| $L_{margin}$ | マージン         | 8.0 dB |

---

## 受信電力計算

$$P_{rx} = P_{tx} + G_{tx} + G_{rx} - PL - L_{margin}$$

| 記号     | 説明             | 値   |
| :------- | :--------------- | :--- |
| $G_{tx}$ | 送信アンテナ利得 | 0 dB |
| $G_{rx}$ | 受信アンテナ利得 | 0 dB |

---

## SINR 計算

### 干渉モデル

周波数分割により、マクロセルとマイクロセルは隣接サブバンドを使用。
ACIR（Adjacent Channel Interference power Ratio）モデルで隣接チャネル干渉を計算。

$$SINR = \frac{S}{I_{aci} + N_0}$$

| 記号      | 説明                             |
| :-------- | :------------------------------- |
| $S$       | サービングセルからの受信電力 [W] |
| $I_{aci}$ | 隣接チャネル干渉電力 [W]         |
| $N_0$     | 熱雑音電力 [W]                   |

---

### ACIR パラメータ（3GPP 準拠）

#### ACLR（送信側漏洩性能）

NR BS の隣接キャリア漏洩電力比。

| パラメータ  | 値    | 出典                           |
| :---------- | :---- | :----------------------------- |
| $ACLR_{dB}$ | 45 dB | 3GPP TS 38.104 Table 6.6.3.2-1 |

#### ACS（受信側選択度）

NR UE の隣接チャネル選択度。Sub-6 ローカル 5G（FR1, $f \geq 3300$ MHz）の場合:

| パラメータ | 値    | 出典                         |
| :--------- | :---- | :--------------------------- |
| $ACS_{dB}$ | 33 dB | 3GPP TS 38.101-1 Table 7.5-2 |

#### ACIR 合成（線形）

$$\frac{1}{ACIR_{lin}} = \frac{1}{ACLR_{lin}} + \frac{1}{ACS_{lin}}$$

| パラメータ  | 値      |
| :---------- | :------ |
| $ACIR_{dB}$ | 32.7 dB |

出典: 3GPP TR 25.942 clause 9.1.2.5

---

### 隣接チャネル干渉電力

干渉源から被干渉 UE への受信電力を ACIR で減衰:

$$I_{aci} = \frac{P_{rx,interferer}}{ACIR_{lin}}$$

$$P_{rx,interferer} = P_{tx,interferer} \cdot G_{tx} \cdot G_{rx} / PL_{lin}$$

---

### 熱雑音電力

$$N_0 = -174 + 10\log_{10}(B_{Hz}) \quad [dBm]$$

| パラメータ | 値      |
| :--------- | :------ |
| 帯域幅 $B$ | 100 MHz |
| $N_0$      | -94 dBm |

---

### 同一チャネル干渉（No Sharing）

周波数分割を行わない場合（No Sharing）、同一チャネル干渉が発生する。
ACIR による減衰がないため、他基地局からの受信電力がそのまま干渉電力となる：

$$I_{co} = P_{rx,interferer}$$

| 干渉モデル              | 減衰量  | 使用場面                   |
| :---------------------- | :------ | :------------------------- |
| 隣接チャネル干渉（ACI） | 32.7 dB | Static Division, Optimized |
| 同一チャネル干渉（CCI） | 0 dB    | No Sharing                 |

---

## 動的 SINR 再計算

シミュレーション実行中に送信電力が変更された場合、各 UE の SINR/CQI を再計算する必要がある。

### 計算フロー

1. **パスロス計算**: UE 位置から各 gNB までの距離を計算し、パスロスを算出
2. **受信電力計算**: サービングセルからの受信電力 $S$ を計算
3. **干渉電力計算**: 干渉セルからの受信電力を ACIR で減衰して $I_{aci}$ を算出
4. **SINR 計算**: $SINR = S / (I_{aci} + N_0)$
5. **CQI 変換**: SINR から CQI (1-15) を導出

### 適用タイミング

- **送信電力変更時**: Optimized Sharing でマイクロセル送信電力が変更された時、両セルの全 UE を再計算
- **同一チャネル干渉適用時**: No Sharing モードでシミュレーション開始時に一度再計算

---

## SINR → CQI 変換

$$
CQI = \begin{cases}
1 & \text{if } SINR \leq -14 \\
\lfloor 0.4875 \cdot SINR + 8.6113 \rfloor & \text{if } -14 < SINR \leq 13 \\
15 & \text{if } SINR > 13
\end{cases}
$$

CQI の範囲: $[1, 15]$

---

## CQI → MCS マッピング

3GPP TS 38.214 準拠:

| CQI | 変調方式 | 符号化率 | 変調次数 |
| :-- | :------- | :------- | :------- |
| 1   | QPSK     | 78/1024  | 2        |
| 2   | QPSK     | 193/1024 | 2        |
| 3   | QPSK     | 449/1024 | 2        |
| 4   | 16QAM    | 378/1024 | 4        |
| 5   | 16QAM    | 490/1024 | 4        |
| 6   | 16QAM    | 616/1024 | 4        |
| 7   | 64QAM    | 466/1024 | 6        |
| 8   | 64QAM    | 567/1024 | 6        |
| 9   | 64QAM    | 666/1024 | 6        |
| 10  | 64QAM    | 772/1024 | 6        |
| 11  | 64QAM    | 873/1024 | 6        |
| 12  | 256QAM   | 711/1024 | 8        |
| 13  | 256QAM   | 797/1024 | 8        |
| 14  | 256QAM   | 885/1024 | 8        |
| 15  | 256QAM   | 948/1024 | 8        |

---

## MIMO（Multiple-Input Multiple-Output）

本シミュレーションでは **SU-MIMO (Single-User MIMO)** をサポートする。

### MIMO モデル

単一ユーザーに対して複数の空間ストリーム（レイヤー）を使用し、スループットを向上させる。

$$C_{MIMO} = N_{layers} \cdot C_{SISO}$$

| パラメータ   | 説明                    | デフォルト値 |
| :----------- | :---------------------- | :----------- |
| $N_{layers}$ | MIMO レイヤー数         | 4            |
| $C_{SISO}$   | SISO 時のスループット   | -            |
| $C_{MIMO}$   | MIMO 適用後スループット | -            |

### 5G NR MIMO 構成

| 構成         | アンテナ数 (gNB) | アンテナ数 (UE) | レイヤー数 | 備考                       |
| :----------- | :--------------- | :-------------- | :--------- | :------------------------- |
| 2x2 MIMO     | 2                | 2               | 2          | 基本構成                   |
| **4x4 MIMO** | 4                | 4               | **4**      | **本シミュレーション採用** |
| 8x4 MIMO     | 8                | 4               | 4          | 高容量セル向け             |

### 実効スループット

MIMO を考慮した RB あたりのデータ量：

$$D_{RB,MIMO}(CQI) = N_{layers} \cdot D_{RB}(CQI)$$

---

## RB あたりデータ量

$$D_{RB}(CQI) = N_{symbol} \cdot N_{sc} \cdot M(CQI) \cdot R(CQI)$$

| 記号         | 説明                     | 値           |
| :----------- | :----------------------- | :----------- |
| $N_{symbol}$ | OFDM シンボル数/スロット | 14           |
| $N_{sc}$     | サブキャリア数/RB        | 12           |
| $M(CQI)$     | 変調次数                 | 上記テーブル |
| $R(CQI)$     | 符号化率                 | 上記テーブル |

---

## Rust 実装

### ディレクトリ構成

```
src/channel/
├── mod.rs           # モジュールルート・再エクスポート
├── pathloss.rs      # パスロス計算
├── cqi.rs           # SINR→CQI変換
├── mcs.rs           # CQI→MCSマッピング・RBあたりデータ量
└── sinr.rs          # SINR計算器（SinrCalculator）
```

### パスロスパラメータ

```rust
#[derive(Debug, Clone)]
pub struct PathLossParams {
    pub h_bs: f64,    // 基地局アンテナ高 [m]
    pub h_ue: f64,    // UEアンテナ高 [m]
    pub alpha: f64,   // 距離減衰係数
    pub a_hm: f64,    // 移動局アンテナ高補正 [dB]
    pub b_hb: f64,    // 基地局アンテナ高補正 [dB]
    pub r: f64,       // 建物侵入損失 [dB]
    pub k: f64,       // 地形補正 [dB]
    pub s: f64,       // シャドウイングマージン [dB]
}
```

### 主要関数

```rust
/// パスロス計算（3領域対応）
pub fn calculate_pathloss(dist_m: f64, freq_hz: f64, params: &PathLossParams) -> f64;

/// 受信電力計算
pub fn received_power(tx_power_dbm: f64, tx_gain_db: f64, rx_gain_db: f64, pathloss_db: f64, margin_db: f64) -> f64;

/// SINR→CQI変換
pub fn sinr_to_cqi(sinr_db: f64) -> u8;

/// RBあたりデータ量 [bits]
pub fn data_per_rb(cqi: u8) -> f64;
```

### MCS テーブル

```rust
/// MCSテーブル (変調次数, 符号化率×1024)
const MCS_TABLE: [(u8, u16); 15] = [
    (2, 78),   // CQI 1: QPSK
    (2, 193),  // CQI 2: QPSK
    // ...
    (8, 948),  // CQI 15: 256QAM
];

pub const OFDM_SYMBOLS_PER_SLOT: u32 = 14;
pub const SUBCARRIERS_PER_RB: u32 = 12;
```

### SINR 計算器

```rust
/// UEのチャネル計算に必要な情報
pub struct UeChannelInfo {
    pub position: (f64, f64),      // UE位置 [m]
    pub serving_cell: CellType,    // 接続先セルタイプ
}

/// SINR計算器
pub struct SinrCalculator {
    freq_hz: f64,              // 中心周波数 [Hz]
    params: PathLossParams,    // パスロスパラメータ
    tx_gain_db: f64,           // 送信アンテナ利得 [dB]
    rx_gain_db: f64,           // 受信アンテナ利得 [dB]
    margin_db: f64,            // マージン [dB]
    noise_power_dbm: f64,      // 熱雑音電力 [dBm]
    acir_linear: f64,          // ACIR減衰係数 (隣接チャネル用)
}

impl SinrCalculator {
    /// SINR/CQIを計算
    pub fn calculate(
        &self,
        ue: &UeChannelInfo,
        macro_pos: (f64, f64),
        micro_pos: (f64, f64),
        macro_tx_power_dbm: f64,
        micro_tx_power_dbm: f64,
    ) -> (f64, u8);
}
```
