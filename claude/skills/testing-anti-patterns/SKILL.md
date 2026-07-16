---
name: testing-anti-patterns
description: Reference for common testing anti-patterns. Use when writing or changing tests, adding mocks, or when tempted to add test-only methods to production code.
---

# Testing Anti-Patterns

**Core principle:** test what the code does, not what the mocks do. Mocks isolate — they are not the thing under test.

TDD prevents most of these. Write the test first, watch it fail against real code, and reach for mocks only when a real dependency is genuinely in the way.

## 1. Don't assert on mock existence

Asserting on a mocked element proves the mock is wired up — it says nothing about the real component.

```typescript
// BAD — confirms the mock, not the page
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});

// GOOD — render the real sidebar and assert on its real output
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});
```

If a dependency must be mocked for isolation, don't assert on the mock. Assert on the behavior the component under test produces with that dependency present.

## 2. Don't add test-only methods to production classes

A `destroy()` method called only from `afterEach` is test infrastructure masquerading as production API. It becomes accidentally callable in prod and confuses the class's real lifecycle.

```typescript
// BAD — Session owns no lifecycle in production, but exposes destroy() for tests
class Session {
  async destroy() {
    await this.workspaceManager?.destroyWorkspace(this.id);
  }
}

// GOOD — cleanup lives in test utilities
// test-utils/cleanup.ts
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) await workspaceManager.destroyWorkspace(workspace.id);
}
```

Before adding a method to a production class, ask whether it's only used by tests. If yes, move it to a test helper.

## 3. Understand a dependency before mocking it

Over-mocking silently removes side effects the test depends on.

```typescript
// BAD — the mock strips the config write the duplicate-detection test relies on
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined),
}));
await addServer(config);
await addServer(config); // silently succeeds — duplicate check never runs

// GOOD — mock the slow external part only; preserve the real config write
vi.mock('MCPServerManager');
await addServer(config);
await addServer(config); // duplicate detected
```

If unsure what a test depends on, run it against real code first and observe what actually needs to happen. Then mock at the lowest level — the slow or external operation — not the high-level method the test depends on.

## 4. Mirror real response shapes completely

Partial mocks fail the moment downstream code touches a field you didn't include.

```typescript
// BAD — missing metadata; breaks when anything reads response.metadata.requestId
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
};

// GOOD — full shape
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 },
};
```

Check the real response (docs, a real call, a recorded fixture) and mirror its full shape. When in doubt, include all documented fields.

## 5. Tests aren't an afterthought

"Implementation done, ready for testing" means the feature isn't done. Follow red-green-refactor: failing test first, minimal code to pass, then refactor.

## When mocks start to hurt

- Mock setup is longer than the test itself
- Mocks drift from the real component's methods
- Test breaks when the mock changes, not when behavior changes
- Can't explain, in a sentence, why the mock is needed

When any of these show up, try an integration test with real components instead. It's usually simpler than a tall stack of mocks.
