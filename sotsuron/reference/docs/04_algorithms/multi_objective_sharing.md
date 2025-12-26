# 観測ベース多目的最適化 (Observation-Based Multi-Objective Sharing)

## 概要

マイクロセル（Microcell: m）を優先して RB を割り当て、残余リソースをマクロセル（Macrocell: M）が使用する周波数分割方式において、**周波数利用効率（SE）** と **エネルギー効率（EE）** を同時に最大化する手法を提案する。

異なるスケールを持つ SE と EE を統合するため、**コブ・ダグラス型効用関数** を採用する。

> [!IMPORTANT] > **設計思想**: マイクロセルの優先度を維持しつつ、SE と EE のバランスを重み係数で柔軟に調整可能。

---

## 1. システムモデル

### 1.1 共通定義

| 記号                               | 説明                                                         |
| :--------------------------------- | :----------------------------------------------------------- |
| $W$                                | システム帯域幅                                               |
| $N_{\mathrm{RB}}^{\mathrm{total}}$ | 総 RB 数                                                     |
| $N_{\mathrm{RB}}^k$                | セル $k$ への割当 RB 数 ($k \in \{\mathrm{m}, \mathrm{M}\}$) |
| $B^k$                              | セル $k$ の帯域幅                                            |
| $T$                                | 観測期間                                                     |

セル $k$ の帯域幅は次式で定義される:

$$B^k = W \cdot \frac{N_{\mathrm{RB}}^k}{N_{\mathrm{RB}}^{\mathrm{total}}}$$

### 1.2 観測パラメータ

基地局側で取得可能な観測値:

| 記号                      | 説明                                     |
| :------------------------ | :--------------------------------------- |
| $R_{\mathrm{obs}}^k$      | 観測スループット (DL UE Throughput)      |
| $\lambda^k$               | 到来量 (Ingress data at PDCP)            |
| $\bar{D}^k$               | 観測された平均遅延 (MAC/RLC measurement) |
| $P_{\mathrm{out}}^k$      | パケットドロップ率 (RLC SDU drop rate)   |
| $\gamma_{\mathrm{obs}}^k$ | CQI 報告に基づく観測 SINR                |
| $P_{\mathrm{t, ref}}^k$   | 観測時の送信電力                         |
| $N_{\mathrm{RB, obs}}^k$  | 観測時の割り当て RB 数                   |

---

## 2. マイクロセルの定式化

### 2.1 SINR 予測

マイクロセルの SINR は送信電力密度に比例すると仮定する。マクロセルからの干渉はフロアノイズとして扱う近似を用いる。

$$\hat{\gamma}^{\mathrm{m}} = \gamma_{\mathrm{obs}}^{\mathrm{m}} \cdot \frac{P_{\mathrm{t}}^{\mathrm{m}}}{P_{\mathrm{t, ref}}^{\mathrm{m}}} \cdot \frac{N_{\mathrm{RB, obs}}^{\mathrm{m}}}{N_{\mathrm{RB}}^{\mathrm{m}}}$$

### 2.2 物理容量

ドロップ率を考慮した物理容量:

$$C^{\mathrm{m}} = B^{\mathrm{m}} \cdot \log_2 \left( 1 + \hat{\gamma}^{\mathrm{m}} \right) \cdot \left(1 - P_{\mathrm{out}}^{\mathrm{m}}\right)$$

### 2.3 トラフィック需要

リトルの法則より算出:

$$R_{\mathrm{req}}^{\mathrm{m}} = \lambda^{\mathrm{m}} + \frac{\lambda^{\mathrm{m}} \bar{D}^{\mathrm{m}}}{T}$$

### 2.4 予測スループット

需要と容量のボトルネックにより決定:

$$\hat{R}^{\mathrm{m}} = \min \left( C^{\mathrm{m}}, R_{\mathrm{req}}^{\mathrm{m}} \right)$$

---

## 3. マクロセルの定式化

マクロセルは残余 RB を使用: $N_{\mathrm{RB}}^{\mathrm{M}} = N_{\mathrm{RB}}^{\mathrm{total}} - N_{\mathrm{RB}}^{\mathrm{m}}$

マクロセルの総送信電力は一定とし、マイクロセルからの干渉変動は無視する。

### 3.1 SINR 予測

$$\hat{\gamma}^{\mathrm{M}} = \gamma_{\mathrm{obs}}^{\mathrm{M}} \cdot \frac{N_{\mathrm{RB, obs}}^{\mathrm{M}}}{N_{\mathrm{RB}}^{\mathrm{M}}}$$

### 3.2 予測スループット

$$\hat{R}^{\mathrm{M}} = \min \left( B^{\mathrm{M}} \log_2(1 + \hat{\gamma}^{\mathrm{M}})(1 - P_{\mathrm{out}}^{\mathrm{M}}), R_{\mathrm{req}}^{\mathrm{M}} \right)$$

---

## 4. 周波数利用効率 (Spectral Efficiency)

システム全体の予測周波数利用効率 [bps/Hz]:

$$\hat{\eta}_{\mathrm{SE}}^{\mathrm{sys}} = \frac{\hat{R}^{\mathrm{m}} + \hat{R}^{\mathrm{M}}}{W}$$

---

## 5. エネルギー効率 (Energy Efficiency)

### 5.1 消費電力モデル

マイクロセルの総消費電力 [W]:

$$P_{\mathrm{c}}^{\mathrm{m}} = P_{\mathrm{fix}}^{\mathrm{m}} + \xi P_{\mathrm{t}}^{\mathrm{m}}$$

- $P_{\mathrm{fix}}^{\mathrm{m}}$: 固定回路電力
- $\xi = 1/\eta_{\mathrm{PA}}$: 消費電力係数（PA 効率 40%の場合、$\xi = 2.5$）

### 5.2 エネルギー効率

マイクロセルのエネルギー効率 [bits/J]:

$$\hat{\eta}_{\mathrm{EE}}^{\mathrm{m}} = \frac{\min \left( C^{\mathrm{m}}, R_{\mathrm{req}}^{\mathrm{m}} \right)}{P_{\mathrm{fix}}^{\mathrm{m}} + 2.5 P_{\mathrm{t}}^{\mathrm{m}}}$$

---

## 6. 最適化問題

### 6.1 決定変数

#### RB 数の離散集合

$$\mathcal{N} = \left\{ n \mid n \in \mathbb{Z}, 1 \le n \le N_{\mathrm{RB}}^{\mathrm{total}} \right\}$$

#### 送信電力の離散集合（1dB 刻み）

$$\mathcal{P} = \left\{ P \mid P_{\mathrm{dB}} \in \{ P_{\mathrm{min, dB}}, P_{\mathrm{min, dB}} + 1, \dots, P_{\mathrm{max, dB}} \}, P = 10^{\frac{P_{\mathrm{dB}} - 30}{10}} \right\}$$

#### トラフィック負荷

$$\rho^k = \frac{R_{\mathrm{req}}^k}{\hat{R}_{\mathrm{cap}}^k}$$

### 6.2 目的関数

コブ・ダグラス型効用関数（対数変換形式）:

$$U(P_{\mathrm{t}}^{\mathrm{m}}, N_{\mathrm{RB}}^{\mathrm{m}}) = w \ln \left( \hat{\eta}_{\mathrm{SE}}^{\mathrm{sys}} \right) + (1 - w) \ln \left( \hat{\eta}_{\mathrm{EE}}^{\mathrm{m}} \right)$$

- $w \in [0, 1]$: 重み係数（SE と EE のバランス調整）

> [!TIP]
> 対数変換により、異なるスケールの SE と EE を公平に扱いつつ、数値計算の安定性が向上する。

### 6.3 制約条件

$$
\begin{align}
\text{maximize} \quad & U(P_{\mathrm{t}}^{\mathrm{m}}, N_{\mathrm{RB}}^{\mathrm{m}}) \\
\text{subject to} \quad & N_{\mathrm{RB}}^{\mathrm{m}} \in \mathcal{N} \\
& P_{\mathrm{t}}^{\mathrm{m}} \in \mathcal{P} \\
& \rho^{\mathrm{m}} \le \rho^{\mathrm{M}}
\end{align}
$$

> [!IMPORTANT]
> 負荷制約 $\rho^{\mathrm{m}} \le \rho^{\mathrm{M}}$ により、マイクロセルに十分なリソースが優先的に割り当てられる。

---

## 7. 比較ベースライン

|  #  | 手法              | 説明                     |
| :-: | :---------------- | :----------------------- |
|  1  | Static Partition  | Micro/Macro 固定 RB 分割 |
|  2  | Optimized Sharing | 従来の最適化手法         |
|  3  | No Sharing        | 共用なし                 |
|  4  | **Proposed**      | 観測ベース多目的最適化   |

---

## 8. 評価指標

### 8.1 周波数利用効率

- システム全体の SE [bps/Hz]
- 各セルの達成スループット

### 8.2 エネルギー効率

- マイクロセルの EE [bits/J]
- システム全体の消費電力

### 8.3 QoS

- パケットドロップ率
- 達成スループット vs 要求量

---

## 関連ドキュメント

- [評価指標](./metrics.md) - 各指標の定義
- [静的分割](./static_division.md) - 比較手法
- [既存の最適化手法](./optimized_sharing.md) - 従来手法
