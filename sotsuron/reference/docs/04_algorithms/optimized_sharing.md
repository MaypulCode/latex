# 二段階最適化（提案手法）

## 概要

マイクロセル（優先）とマクロセル（非優先）のリソース利用率の差を最小化する提案手法。

**入力**: データセットに含まれる過去の履歴メトリクス（`history.parquet`）を参照して最適化を実行。

---

## 第 1 段階: RB 割当最適化

### 目的

マイクロセルとマクロセルの RB 使用率の差を最小化。

### RB 使用率

$$U_{micro} = \frac{N_{RB,used}^{micro}}{N_{RB}^{micro}} = \frac{\bar{R}_{micro} / D_{RB}(\bar{CQI}_{micro})}{N_{RB}^{micro}}$$

$$U_{macro} = \frac{N_{RB,used}^{macro}}{N_{RB}^{macro}} = \frac{\bar{R}_{macro} / D_{RB}(\bar{CQI}_{macro})}{N_{RB}^{macro}}$$

### 最適化問題

$$\min_{N_{RB}^{micro}} |U_{micro} - U_{macro}|$$

制約条件:

- $N_{RB}^{micro} + N_{RB}^{macro} = 273$
- $U_{micro} < 1$（マイクロセル利用率が 1 未満）
- $U_{micro} < U_{macro}$（マイクロセル優先）

### 探索アルゴリズム（二分探索）

```
min_rb ← 1, max_rb ← 273
best_rb ← 273, min_diff ← ∞

while min_rb ≤ max_rb do
    mid ← (min_rb + max_rb) / 2

    U_micro ← (R̄_micro / D_RB(CQI_micro)) / mid
    U_macro ← (R̄_macro / D_RB(CQI_macro)) / (273 - mid)
    diff ← U_micro - U_macro

    if |diff| < min_diff and U_micro < 1 and U_micro < U_macro then
        min_diff ← |diff|
        best_rb ← mid

    if diff > 0 then
        min_rb ← mid + 1
    else
        max_rb ← mid - 1
end while
```

---

## 第 2 段階: 送信電力最適化

### 目的

マイクロセル利用率が閾値を超える場合、送信電力を増加して CQI を改善。

### 条件

- 利用率閾値: $\theta = 0.9$
- $U_{micro} \geq \theta$ の場合に送信電力調整を実施

### 送信電力と CQI の関係

$$SINR_{new} = SINR_{base} + \Delta P$$
$$CQI_{new} = f_{CQI}(SINR_{new})$$

### 送信電力制約

$$P_{tx,min}^{micro} \leq P_{tx}^{micro} \leq P_{tx,max}^{micro}$$

- $P_{tx,min}^{micro} = 7$ dBm（初期値）
- $P_{tx,max}^{micro}$: マイクロセルがマクロセル内に収まる最大値

### 探索アルゴリズム

```
if U_micro ≥ θ then
    min_tx ← P_min, max_tx ← P_max
    best_tx ← max_tx

    while max_tx - min_tx > 1 do
        mid ← (min_tx + max_tx) / 2
        Δ ← mid - P_min

        SINR_est ← SINR_base + Δ
        CQI_est ← convert_cqi(SINR_est)
        U_est ← (R̄_micro / D_RB(CQI_est)) / N_RB^micro

        if U_est < θ then
            best_tx ← mid
            max_tx ← mid
        else
            min_tx ← mid
    end while
end if
```

---

## 関連ドキュメント

- [静的分割](./static_division.md) - 比較手法
- [評価指標](./metrics.md) - 公平性評価
