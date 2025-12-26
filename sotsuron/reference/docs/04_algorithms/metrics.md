# 評価指標

## 概要

シミュレーション結果を評価するための指標定義。

---

## 1. 周波数利用効率

$$\eta_{freq} = \frac{\sum_{u \in \mathcal{U}} D_{tx,u}}{BW \cdot T_{sim}}$$

単位: [bps/Hz]

| 記号       | 説明                           |
| :--------- | :----------------------------- |
| $D_{tx,u}$ | UE $u$ の総送信データ量 [bits] |
| $BW$       | システム帯域幅 [Hz]            |
| $T_{sim}$  | シミュレーション時間 [s]       |

---

## 2. RB 使用率（需要ベース）

RB 使用率は、割り当てられた RB 容量に対するトラフィック需要の比率として定義。

> [!IMPORTANT]
> 需要ベースで計算することで、基地局間距離が近く干渉が大きい場合に利用率が上昇する。

$$U_{cell} = \min\left( \frac{D_{demand}^{cell}}{C_{RB}^{cell}}, 1.0 \right)$$

| 記号                | 説明                                                           |
| :------------------ | :------------------------------------------------------------- |
| $D_{demand}^{cell}$ | そのステップでのトラフィック需要 [bits]                        |
| $C_{RB}^{cell}$     | 割当 RB 容量 = $N_{RB}^{cell} \times D_{RB}(\bar{CQI})$ [bits] |

### 補足: 使用 RB 数

実際に使用した RB 数も別途追跡する:

$$N_{RB,used}^{cell} = \sum_{u \in \mathcal{U}_{cell}} \mathbf{1}_{tx\_bits > 0} \cdot N_{RB,u}$$

---

## 3. RB 使用率公平性（Jain's Fairness Index）

$$J = \frac{(U_{macro} + U_{micro})^2}{2 \cdot (U_{macro}^2 + U_{micro}^2)}$$

| 値        | 意味                               |
| :-------- | :--------------------------------- |
| $J = 1$   | 完全公平（両セルの利用率が等しい） |
| $J = 0.5$ | 最も不公平（一方のみが利用）       |

---

## 4. エネルギー効率

$$EE = \frac{R_{total}}{P_{total}} \quad [\text{bit/Joule}]$$

### 消費電力モデル

$$P_{total} = \sum_{i \in \{macro, micro\}} \left( \frac{P_{tx,i}}{\eta} + P_{circuit,i} \right)$$

| 記号                  | 説明                      | 値    |
| :-------------------- | :------------------------ | :---- |
| $\eta$                | 電力増幅器効率            | 0.35  |
| $P_{circuit}^{macro}$ | マクロ gNB 固定回路電力   | 130 W |
| $P_{circuit}^{micro}$ | マイクロ gNB 固定回路電力 | 56 W  |

---

## 5. セルスループット

$$R_{cell} = \sum_{u \in \mathcal{U}_{cell}} D_{tx,u}$$

単位: [bits/s]

---

## 6. 平均遅延時間

パケットが到着してから送信完了までの平均時間。

$$\bar{\tau}_{cell} = \frac{1}{N_{tx}} \sum_{p \in \mathcal{P}_{tx}} (t_{tx,p} - t_{arr,p})$$

| 記号        | 説明                        |
| :---------- | :-------------------------- |
| $N_{tx}$    | 送信完了パケット数          |
| $t_{arr,p}$ | パケット $p$ の到着時刻     |
| $t_{tx,p}$  | パケット $p$ の送信完了時刻 |

単位: [ms]

> [!NOTE]
> 期限切れでドロップされたパケットは平均遅延の計算には含まれません。

---

## 7. トラフィック充足率

要求されたトラフィック量に対する実際に送信されたトラフィック量の比率。

$$S_{cell} = \frac{\sum_{p \in \mathcal{P}_{tx}} D_p}{\sum_{p \in \mathcal{P}_{all}} D_p}$$

| 記号                | 説明                               |
| :------------------ | :--------------------------------- |
| $\mathcal{P}_{tx}$  | 送信完了パケット集合               |
| $\mathcal{P}_{all}$ | 全到着パケット集合                 |
| $D_p$               | パケット $p$ のデータサイズ [bits] |

| 値      | 意味                               |
| :------ | :--------------------------------- |
| $S = 1$ | 全トラフィックを送信完了           |
| $S < 1$ | 一部のパケットが期限切れでドロップ |

---

## 8. パケットロス率

許容遅延時間（$\tau_{\text{max}}$）を超過してドロップされたパケットの割合。

$$PLR_{cell} = \frac{N_{drop}^{cell}}{N_{total}^{cell}}$$

| 記号               | 説明                     |
| :----------------- | :----------------------- |
| $N_{drop}^{cell}$  | ドロップされたパケット数 |
| $N_{total}^{cell}$ | 到着した全パケット数     |

| 値        | 意味                           |
| :-------- | :----------------------------- |
| $PLR = 0$ | パケットロスなし（全送信完了） |
| $PLR = 1$ | 全パケットがドロップ           |

> [!NOTE]
> パケットロス率とトラフィック充足率の関係:
> パケットロス率はパケット数ベース、充足率はデータ量ベースで計算される。
> パケットサイズが均一でない場合、両指標は異なる値になる。

---

## CSV 出力カラム

| カラム                 | 説明                       |
| :--------------------- | :------------------------- |
| `macro_avg_cqi`        | マクロセル平均 CQI         |
| `macro_allocated_rbs`  | マクロセル平均割当 RB 数   |
| `macro_utilization`    | マクロセル RB 使用率       |
| `macro_avg_delay_ms`   | マクロセル平均遅延時間     |
| `micro_avg_cqi`        | マイクロセル平均 CQI       |
| `micro_allocated_rbs`  | マイクロセル平均割当 RB 数 |
| `micro_utilization`    | マイクロセル RB 使用率     |
| `micro_avg_delay_ms`   | マイクロセル平均遅延時間   |
| `fairness_index`       | Jain's Fairness Index      |
| `frequency_efficiency` | 周波数利用効率             |
| `energy_efficiency`    | エネルギー効率             |
| `macro_throughput`     | マクロセルスループット     |
| `micro_throughput`     | マイクロセルスループット   |
| `macro_satisfaction`   | マクロセル充足率           |
| `micro_satisfaction`   | マイクロセル充足率         |
| `macro_packet_loss`    | マクロセルパケットロス率   |
| `micro_packet_loss`    | マイクロセルパケットロス率 |

---

## Rust 実装

```rust
impl Metrics {
    /// Jain's Fairness Indexを計算
    pub fn calculate_fairness(u_macro: f64, u_micro: f64) -> f64 {
        let sum = u_macro + u_micro;
        let sum_sq = u_macro.powi(2) + u_micro.powi(2);
        if sum_sq == 0.0 { 0.5 } else { sum.powi(2) / (2.0 * sum_sq) }
    }
}
```
