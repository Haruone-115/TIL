# React 状態管理パターン: Context API vs Props+State

## 概要

React での状態管理には大きく2つのパターンがあります。それぞれの特徴と使い分けを解説します。

---

## 1. Props + State パターン（ローカル状態）

### 概念

```
┌─────────────────────────────────────────┐
│ Parent Component                        │
│                                         │
│   const [value, setValue] = useState()  │
│                     │                   │
│                     ▼ props             │
│         ┌───────────────────┐           │
│         │  Child Component  │           │
│         │   value={value}   │           │
│         │   onChange={...}  │           │
│         └───────────────────┘           │
└─────────────────────────────────────────┘
```

### 特徴

| 観点             | 説明                                   |
| ---------------- | -------------------------------------- |
| **データの流れ** | 親 → 子へ props で明示的に渡す         |
| **スコープ**     | 状態を持つコンポーネントとその子孫のみ |
| **追跡性**       | どこから来たデータか一目瞭然           |
| **再利用性**     | 高い（依存が明示的）                   |

### コード例

```tsx
// 親コンポーネント
const Parent = () => {
  const [toast, setToast] = useState<ToastState>(undefined);

  const showToast = (message: string) => {
    setToast({ message, variant: "info" });
  };

  const clearToast = () => setToast(undefined);

  return (
    <>
      <Child onAction={showToast} />
      {toast && <Toast message={toast.message} onClose={clearToast} />}
    </>
  );
};

// 子コンポーネント
const Child = ({ onAction }: { onAction: (msg: string) => void }) => {
  return <button onClick={() => onAction("完了しました")}>実行</button>;
};
```

### 適したケース

- ✅ 状態が1つのコンポーネントまたは親子間でのみ必要
- ✅ コンポーネントの独立性・再利用性を重視
- ✅ データの流れを明確にしたい
- ✅ モーダルやダイアログ内のローカルな状態

---

## 2. Context API パターン（グローバル状態）

### 概念

```
┌─────────────────────────────────────────────────┐
│ Provider                                        │
│   value = { state, actions }                    │
│          ┌─────────┴─────────┐                  │
│          ▼                   ▼                  │
│   ┌────────────┐      ┌────────────┐            │
│   │ ComponentA │      │ ComponentB │            │
│   │ useContext │      │ useContext │            │
│   └────────────┘      └────────────┘            │
│          │                   │                  │
│          └─────────┬─────────┘                  │
│                    ▼                            │
│          どこからでもアクセス可能                 │
└─────────────────────────────────────────────────┘
```

### 特徴

| 観点             | 説明                                     |
| ---------------- | ---------------------------------------- |
| **データの流れ** | Provider から useContext で暗黙的に取得  |
| **スコープ**     | Provider 配下の全コンポーネント          |
| **追跡性**       | やや低い（どこで変更されたか追いにくい） |
| **利便性**       | 高い（props drilling 不要）              |

### コード例

```tsx
// Context 定義
const ToastContext = createContext<ToastContextType | undefined>(undefined);

// Provider コンポーネント
export const ToastProvider = ({ children }) => {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const addToast = (message: string, variant: Variant) => {
    setToasts((prev) => [...prev, { id: Date.now(), message, variant }]);
  };

  return (
    <ToastContext.Provider value={{ addToast }}>
      {children}
      <ToastContainer toasts={toasts} />
    </ToastContext.Provider>
  );
};

// 使用側（どの階層からでも使える）
const DeeplyNestedComponent = () => {
  const { addToast } = useContext(ToastContext);

  return (
    <button onClick={() => addToast("保存しました", "success")}>保存</button>
  );
};
```

### 適したケース

- ✅ 複数の離れたコンポーネントで共有が必要
- ✅ 深い階層への props drilling を避けたい
- ✅ アプリ全体で一貫した状態管理が必要
- ✅ テーマ、認証情報、ユーザー設定など

---

## 3. パターン比較表

| 観点               | Props + State | Context API                  |
| ------------------ | ------------- | ---------------------------- |
| **複雑さ**         | シンプル      | やや複雑                     |
| **スコープ**       | 局所的        | 広域的                       |
| **データの流れ**   | 明示的        | 暗黙的                       |
| **テスタビリティ** | 高い          | Provider のモックが必要      |
| **パフォーマンス** | 良い          | 注意が必要（再レンダリング） |
| **デバッグ**       | 容易          | やや難しい                   |
| **学習コスト**     | 低い          | 中程度                       |

---

## 4. 実践的な使い分け指針

### Props + State を選ぶ

```
「この状態は、このコンポーネントとその直接の子だけが知っていればよいか？」
→ YES なら Props + State
```

**具体例:**

- フォームの入力値
- モーダルの開閉状態
- アコーディオンの展開状態
- ローカルなローディング状態

### Context API を選ぶ

```
「この状態を、離れた複数のコンポーネントが参照/更新する必要があるか？」
→ YES なら Context API
```

**具体例:**

- ログインユーザー情報
- テーマ設定（ダークモード等）
- 言語/ロケール設定
- グローバルな通知（トースト）

---

## 5. よくある落とし穴

### Props + State の落とし穴

```tsx
// ❌ Props Drilling（深い階層への props リレー）
<A>
  <B someProp={value}>
    <C someProp={value}>
      <D someProp={value}>  {/* 実際に使うのはここだけ */}
```

**解決策:** 3階層以上の props リレーが発生したら Context を検討

### Context API の落とし穴

```tsx
// ❌ 何でも Context に入れてしまう
const AppContext = createContext({
  user: null,
  theme: "light",
  notifications: [],
  cart: [],
  // ... どんどん肥大化
});
```

**解決策:** 関連する状態ごとに Context を分割

```tsx
// ✅ 責務ごとに分割
<AuthProvider>
  <ThemeProvider>
    <NotificationProvider>
      <App />
```

---

## 6. 本プロジェクトでの適用例

### ToastOnModal（Props + State パターン）

モーダル内でのみ表示されるトースト通知に使用。

```tsx
// useSendTestWebhook.tsx
const [toast, setToast] = useState<ToastState>(undefined);

// EditWebhookModal.tsx
{
  testSendToast && (
    <ToastOnModal variant={testSendToast.variant} onClose={clearTestSendToast}>
      {testSendToast.message}
    </ToastOnModal>
  );
}
```

**選択理由:**

- トーストはモーダル内でのみ必要
- モーダルが閉じれば状態も破棄される
- 外部に影響を与えない独立した機能

### Toast + ToastProvider（Context API パターン）

モーダルを閉じた後に親画面で表示するトースト通知に使用。

```tsx
// useUpsertWebhook.tsx
const { addToast } = useToastContext();

onCompleted: () => {
  addToast({ variant: "info", message: "保存しました" });
  onSuccess(); // モーダルを閉じる
};
```

**選択理由:**

- モーダル（子）から親画面にトーストを表示したい
- モーダルを閉じた後もトーストを維持したい
- 深いネストからでも呼び出したい

---

## 7. まとめ

> **原則: 「シンプルな方から始める」**
>
> まず Props + State で実装し、
> props drilling が煩雑になったら Context を検討する。

状態管理の選択は「正解」があるわけではなく、トレードオフです。
コードの可読性、保守性、チームの習熟度を考慮して選択しましょう。
