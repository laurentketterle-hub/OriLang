# Array Bounds Bug Hunt (Issue #18)

## Edge Cases Found

### 1. Out-of-bounds access
Accessing arr[idx] where idx >= len(arr) or idx < 0 causes undefined behavior.

### 2. Empty array edge cases
Operations on empty arrays (len=0) need careful handling.

### 3. Push semantics
push(arr, val) grows the array; all previous indices remain valid.

## Safe Access Helpers
- safe_get(arr, idx, default): bounds-checked get with fallback
- safe_set(arr, idx, val): bounds-checked set, returns success
- is_valid_idx(arr, idx): check if index is valid

See samples/array_safe.ori for implementations.