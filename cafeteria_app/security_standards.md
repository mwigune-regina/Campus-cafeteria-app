# Security Standards & Best Practices

This document outlines the security protocols and coding standards adhered to during the development of the Campus Cafeteria App.

## 1. Authentication & Authorization
*   **Password Hashing**: Never store plain-text passwords. Use `bcryptjs` with a cost factor of at least 12.
*   **JWT Security**: Tokens are signed with a strong `JWT_SECRET` stored in environment variables. Tokens have a short lifespan (e.g., 2 hours).
*   **Role-Based Access Control (RBAC)**: Use middleware (`role_middleware.js`) to enforce permissions. High-privilege actions (like adding menu items) must be restricted to the `admin` role.
*   **Statelessness**: Favor JWTs over sessions to prevent CSRF attacks and simplify horizontal scaling.

## 2. Data Protection
*   **Frontend Storage**: Sensitive data like JWTs must be stored using `flutter_secure_storage` (Keychain for iOS, Keystore for Android) instead of plain-text `shared_preferences`.
*   **Input Sanitization**: Trim and sanitize all user inputs on the backend to prevent NoSQL/SQL injection and cross-site scripting (XSS).
*   **Sensitive Data Exposure**: Ensure backend error messages are generic (e.g., "Invalid credentials" instead of "User not found") to prevent user enumeration.

## 3. Network Security
*   **Security Headers**: Use `helmet.js` in the Express backend to set secure HTTP headers (HSTS, CSP, Frameguard, etc.).
*   **CORS**: Configure Cross-Origin Resource Sharing (CORS) to only allow requests from trusted domains.
*   **Rate Limiting**: Implement `express-rate-limit` on all authentication and sensitive endpoints to prevent brute-force and Denial of Service (DoS) attacks.
*   **SSL/TLS**: All production traffic must be served over HTTPS.

## 4. API & Database Integrity
*   **Parametrized Queries**: Always use placeholders (e.g., `$1, $2`) in SQL queries to prevent SQL Injection.
*   **Source of Truth**: Never trust client-side data for sensitive calculations. For example, fetch the price of an item from the database during checkout rather than using the price sent from the mobile app.
*   **Transactions**: Use SQL Transactions (`BEGIN`, `COMMIT`, `ROLLBACK`) for operations involving multiple tables (like placing an order) to ensure data atomicity.

## 5. Daily Development Workflow
*   **Environment Variables**: Never hardcode API keys, database credentials, or secrets. Use `.env` files and include them in `.gitignore`.
*   **Dependency Audits**: Regularly run `npm audit` and `flutter pub outdated` to check for known vulnerabilities in third-party packages.
*   **Error Logging**: Log internal errors to the server console (using `console.error`) but return clean, non-descriptive error messages to the client.
