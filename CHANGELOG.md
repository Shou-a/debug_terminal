## 1.1.0

*   **🎯 Tap-Outside-to-Collapse**: Tapping anywhere outside the terminal panel now collapses it to just the header bar — it no longer fully hides. The app behind remains fully interactive (no barrier widget is used; a `GlobalKey` bounds-check is used instead).
*   **📋 Copy-to-Clipboard per Section**: Each expanded log section (REQUEST BODY, RESPONSE BODY, ERROR, etc.) now has a dedicated copy icon. A snackbar confirms the copy action.
*   **🔍 Plain Log vs API Log distinction**: `log()` entries now display a dedicated `DATA` section instead of sharing the API log layout. API logs (`logApi`, `logError`) continue to show their full request/response detail.

## 1.0.0

*   **Initial Stable Release** 🚀
*   **🕵️ Stealth Activation**: Secret long-press gesture with customizable duration.
*   **🔒 Secure PIN-Gate**: Protection via a custom keypad overlay.
*   **🚀 New Activation Methods**:
    *   **Combo Taps**: Configure the console to open on double, triple, or quad-tap.
    *   **Floating Button**: Added a positionable FAB (Debug-only) for instant access.
    *   **Shortcut Bypass**: Option to skip the PIN entry when using visible shortcuts.
*   **📡 Specialized Logging**:
    *   `logApi`: Rich inspection for network requests, responses, and query params.
    *   `logError`: Dedicated tracking for exceptions and stack traces.
*   **🎨 Dynamic Theme**: Fully configurable primary color and icon set.
*   **📖 Developer Experience**:
    *   Enterprise-grade README with complete setup guides.
    *   Internal documentation for all public API members.
    *   Dedicated example project for quick integration testing.
