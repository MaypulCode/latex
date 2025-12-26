# 並列処理アーキテクチャ

## 概要

Rust の`rayon`クレートを使用した並列処理により、データ生成とシミュレーションの高速化を実現する。

---

## rayon の並列化モデル

> [!IMPORTANT] > `par_iter()`は**全タスクを同時実行するわけではない**。スレッドプール（デフォルト: CPU コア数）で順次処理される。

### 動作原理

```
2050シナリオ、8コアの場合:

[タスクキュー: 2050個]
     ↓
[スレッドプール: 8スレッド]
     ↓
同時実行: 最大8シナリオ
     ↓
完了したスレッドが次のタスクを取得（work-stealing）
```

### メモリ使用量

| 方式                 | メモリ使用量    | 備考                       |
| :------------------- | :-------------- | :------------------------- |
| 全データ先読み       | `O(N)`          | N=シナリオ数、OOM リスク大 |
| オンデマンド読み込み | `O(スレッド数)` | **推奨**                   |

---

## 現在の実装

### データ生成 (`generate`)

```rust
// dataset/generator.rs
scenarios.par_iter().map(|...| generate_scenario(...)).collect()
```

- ✅ シナリオ生成: 並列化済み
- ✅ ファイル書き込み: 各シナリオ独立

### シミュレーション (`simulate`)

```rust
// main.rs (最適化済み)
summaries.par_iter().filter_map(|summary| {
    let scenario = loader.load_scenario(...)?;  // オンデマンド読み込み
    let result = sim.run(&scenario, ...);
    Some(result)  // scenario はここでドロップ
}).collect()
```

- ✅ 並列シミュレーション: 全 CPU コア活用
- ✅ オンデマンド読み込み: メモリ効率 `O(スレッド数)`
- ✅ 実行時間: 6 分 35 秒 → 4 分 24 秒（33%短縮）

---

## 最適化設計

### 推奨パターン: オンデマンド読み込み + 並列シミュレーション

```rust
// 推奨実装
summaries.par_iter().filter_map(|summary| {
    // 各スレッドで必要時に読み込み（メモリ効率）
    let scenario = loader.load_scenario(summary.distance, summary.seed).ok()?;

    let mut sim = Simulator::from_scenario(config.clone(), &scenario);
    let result = sim.run(&scenario, summary, &sharing);

    // scenario はここでドロップ → メモリ解放
    Some(result)
}).collect()
```

**利点:**

- メモリ使用量: `O(スレッド数)` のみ
- 距離グループの壁を除去
- 全 CPU コアを常時活用
- Work-stealing による負荷分散

> [!CAUTION]
> 以下のパターンは**OOM リスク**があるため避ける:
>
> ```rust
> // ❌ 危険: 全データを先に読み込む
> let all_scenarios = loader.load_all_parallel(&summaries);
> ```

---

## Rust ベストプラクティス

### メモリ安全性

| 手法       | 説明                     |
| :--------- | :----------------------- |
| `Arc<T>`   | 読み取り専用データの共有 |
| `Clone`    | 設定のコピー（軽量）     |
| 所有権転送 | シナリオデータの移動     |

### 並列化パターン

| パターン          | 用途                       |
| :---------------- | :------------------------- |
| `par_iter()`      | 読み取り専用イテレーション |
| `par_iter_mut()`  | 可変イテレーション         |
| `par_bridge()`    | イテレータを並列化         |
| `into_par_iter()` | 所有権転送して並列化       |

### スレッドプール設定

```rust
use rayon::ThreadPoolBuilder;

ThreadPoolBuilder::new()
    .num_threads(num_cpus::get())
    .build_global()
    .unwrap();
```

---

## 関連ドキュメント

- [実行モデル](./execution_model.md) - 二段階実行フロー
- [データフロー](./dataflow.md) - 処理サイクル
