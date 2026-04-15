# C++ Doxygen Template

Use Doxygen for public API documentation in headers.

## Rules
- Use `/** ... */` comment blocks only.
- Document public classes, structs, enums, functions, methods, and non-obvious public constants.
- Prefer documenting declarations in headers rather than duplicating equivalent docs in source files.
- Use only the approved tags when needed:
  - `@brief`
  - `@param`
  - `@return`
  - `@note`
  - `@warning`
  - `@pre`
  - `@post`
- Do not mix `@param` and `\param` styles.
- Trivial getters, setters, and obvious private helpers do not need Doxygen unless behavior is non-obvious.

## Function Template
```cpp
/**
 * @brief Short summary.
 *
 * Optional longer explanation if needed.
 *
 * @param name Meaning, units, constraints, or ownership expectations.
 * @param timeout_s Maximum wait time in seconds.
 * @return Meaning of the returned value when non-obvious.
 * @pre Required state before calling.
 * @post Guaranteed state after successful completion.
 * @note Side effects, threading assumptions, timing, or call-order caveats.
 * @warning Safety-critical or easy-to-misuse behavior.
 */
bool sendCommand(double name, double timeout_s);
```

## Class Template
```cpp
/**
 * @brief Short summary of the class purpose.
 *
 * Optional explanation of ownership, lifecycle, or operational role when
 * relevant.
 */
class ExampleInterface
{
public:
  /**
   * @brief Construct the interface with the provided device path.
   *
   * @param device_path Stable device path used for connection.
   */
  explicit ExampleInterface(const std::string & device_path);
};
```

## Enum Template
```cpp
/**
 * @brief Result codes returned by the command path.
 */
enum class CommandResult
{
  Success,
  Timeout,
  InvalidInput,
};
```

## Good Patterns
- Describe purpose, units, ownership, side effects, and preconditions.
- Keep wording technical and direct.
- Comment intent and interface contract, not implementation mechanics.

## Avoid
- Narrating obvious code behavior.
- Duplicating the same documentation in header and source without reason.
- Mixing Doxygen tag styles.
- Explaining private implementation details at API boundaries.
