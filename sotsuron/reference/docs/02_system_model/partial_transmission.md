# パケット部分送信（Partial Transmission）仕様

## 概要

大容量パケット（ファイル）を複数スロットにわたって部分的に送信する機能。
RLC (Radio Link Control) のセグメンテーションに相当。

## 背景と問題

- 3GPP FTP Model 3 では平均ファイルサイズが**16 Mbits**
- 1 スロットの送信容量は CQI 15 でも約**600 Kbits**
- パケット単位でしか送信できない場合、大きなパケットは送信不可

## 設計

### Packet 構造体の変更

```rust
pub struct Packet {
    pub id: u64,
    pub arrival_time_s: f64,
    pub size_bits: u64,           // 元のサイズ（不変）
    pub remaining_bits: u64,      // 残り送信ビット数（可変）
    pub deadline_time_s: f64,
}
```

### 送信ロジック

1. 各スロットで送信可能なビット数を計算
2. パケットの`remaining_bits`から送信分を減算
3. `remaining_bits == 0`になったらパケット完了として削除
4. 期限内に完了しなければドロップ

### UE::dequeue の変更

現在:

```rust
// パケット全体を送信できる場合のみ
if total_bits + packet.size_bits <= max_bits {
    removed.push(packet);
}
```

変更後:

```rust
// 部分送信をサポート
let transmit_bits = packet.remaining_bits.min(available_bits);
packet.remaining_bits -= transmit_bits;
total_tx += transmit_bits;

if packet.remaining_bits == 0 {
    removed.push(packet);  // 完了
}
```

### 統計への影響

| 指標         | 変更点                                            |
| :----------- | :------------------------------------------------ |
| スループット | 部分送信したビット数を累積                        |
| パケットロス | `remaining_bits > 0`で期限切れ → ドロップカウント |
| 遅延         | 最後のビット送信時刻 - 到着時刻                   |

## 実装ファイル

1. `src/entities/packet.rs` - `remaining_bits`フィールド追加
2. `src/entities/ue.rs` - `dequeue`を部分送信対応に変更
3. `src/engine/simulator.rs` - 統計計算の調整

## テスト

- 大容量パケット（16 Mbits）が複数スロットで送信完了することを確認
- 期限内に送信完了できるパケットはドロップされないことを確認
- スループット計算が正しいことを確認
