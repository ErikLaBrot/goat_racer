# Python Docstring Template

Use PEP 257 principles with one consistent house format.

## Rules
- Use triple double quotes for all docstrings.
- Start with a short summary line.
- Add a blank line after the summary when additional detail is needed.
- Only include `Args`, `Returns`, `Raises`, or `Notes` when they add useful information.
- Do not repeat obvious type information already present in annotations unless units, constraints, shape, or semantic meaning need clarification.
- Document public modules, classes, and functions. Private helpers may omit docstrings unless behavior is non-obvious.

## Module Template
```python
"""Short module summary.

Optional module context if needed. Keep this focused on purpose and scope.
"""
```

## Class Template
```python
class ExampleController:
    """Short summary of the class purpose.

    Optional notes about invariants, ownership, lifecycle, or operational behavior
    when relevant.
    """
```

## Function or Method Template
```python
def example_function(value: float, timeout_s: float) -> bool:
    """Evaluate the request against the current limit.

    Optional longer explanation if the behavior, state interaction, or call
    expectations are not obvious from the name and signature.

    Args:
        value: Requested value in meters per second.
        timeout_s: Maximum allowed wait time in seconds.

    Returns:
        True if the request completes within the allowed limit.

    Raises:
        ValueError: Requested value is outside the accepted range.

    Notes:
        Blocks until completion or timeout.
    """
```

## Minimal Function Template
Use this when the summary alone is enough.

```python
def clamp_command(command: float) -> float:
    """Clamp the command to the supported output range."""
```

## Good Patterns
- Explain units, ranges, ownership, side effects, and preconditions when needed.
- Summarize what the callable does, not how it does it.
- Keep wording direct and technical.

## Avoid
- Line by line implementation commentary.
- Empty boilerplate sections.
- Restating the type hint in prose with no added value.
- Speculative behavior that is not guaranteed by the code.
