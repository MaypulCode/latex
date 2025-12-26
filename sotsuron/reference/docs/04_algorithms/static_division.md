# 静的周波数分割

## 概要

比較手法として使用する静的な周波数共用方式。帯域を固定比率で分割する。

---

## RB 割当

| セル                 | 割当 RB 数 |
| :------------------- | :--------- |
| マイクロセル（優先） | 137        |
| マクロセル（非優先） | 136        |

$$N_{RB}^{micro} = 137, \quad N_{RB}^{macro} = 136$$

---

## 特徴

| 項目         | 説明         |
| :----------- | :----------- |
| 動的調整     | なし（固定） |
| 送信電力調整 | なし         |
| 計算コスト   | 最小         |
| 適応性       | なし         |

---

## 使用場面

- ベースライン比較
- 提案手法の効果検証

---

## 実装

```rust
pub struct StaticDivision {
    micro_rbs: u32,  // 137
    macro_rbs: u32,  // 136
}

impl SpectrumSharing for StaticDivision {
    fn allocate(&self, ...) -> AllocationResult {
        AllocationResult {
            micro_rbs: self.micro_rbs,
            macro_rbs: self.macro_rbs,
            micro_tx_power_dbm: current_power,
        }
    }
}
```

---

## SpectrumSharing トレイト

```rust
/// 周波数共用トレイト
pub trait SpectrumSharing {
    fn allocate(
        &self,
        micro_metrics: &CellMetrics,
        macro_metrics: &CellMetrics,
        current_tx_power: f64,
        total_rbs: u32,
    ) -> AllocationResult;
}

#[derive(Debug, Clone)]
pub struct AllocationResult {
    pub macro_rbs: u32,
    pub micro_rbs: u32,
    pub micro_tx_power_dbm: f64,
}
```
