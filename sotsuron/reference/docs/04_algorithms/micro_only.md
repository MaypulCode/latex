# マイクロセル専用割当 (Micro Only)

## 概要

比較手法として使用する極端な周波数割当方式。全てのリソースブロックをマイクロセルに割り当て、マクロセルには何も割り当てない。

---

## RB 割当

| セル         | 割当 RB 数  |
| :----------- | :---------- |
| マイクロセル | 全 RB (273) |
| マクロセル   | 0           |

$$N_{RB}^{micro} = N_{RB}^{total}, \quad N_{RB}^{macro} = 0$$

---

## 特徴

| 項目         | 説明                         |
| :----------- | :--------------------------- |
| 動的調整     | なし（固定）                 |
| 送信電力調整 | なし                         |
| 計算コスト   | 最小                         |
| マクロ性能   | 0（サービス不可）            |
| マイクロ性能 | 最大化（全リソース使用可能） |

---

## 使用場面

- マイクロセルの上限性能評価
- 周波数共用効果の検証（共用なしの極端ケース）
- 提案手法との比較

---

## CLI 使用例

```bash
./target/release/local5g-sim simulate \
    --input dataset \
    --output result \
    --method micro_only
```

---

## 実装

```rust
pub struct MicroOnlySharing;

impl SpectrumSharing for MicroOnlySharing {
    fn allocate(
        &self,
        _micro_metrics: &CellMetrics,
        _macro_metrics: &CellMetrics,
        current_tx_power: f64,
        total_rbs: u32,
    ) -> AllocationResult {
        AllocationResult {
            micro_rbs: total_rbs,  // 全 RB をマイクロに
            macro_rbs: 0,          // マクロは 0
            micro_tx_power_dbm: current_tx_power,
        }
    }

    fn name(&self) -> &'static str {
        "Micro Only"
    }
}
```

---

## 期待される結果

| メトリクス     | マクロセル | マイクロセル |
| :------------- | :--------- | :----------- |
| 利用率         | 0%         | 最大         |
| スループット   | 0          | 最大         |
| パケットロス   | 100%       | 最小         |
| 周波数利用効率 | 低         | 高           |
