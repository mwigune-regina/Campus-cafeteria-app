# Project Restructure and Backend Implementation Plan

Comprehensive overhaul of the Cafeteria App to follow best practices for Flutter development and a robust Node.js/Express backend.

## Proposed Changes

### Flutter Project (lib/)

Restructuring into a feature-based architecture with clear separation of concerns.

- **Core**: Global constants, themes, and utility functions.
- **Models**: Data structures with JSON serialization.
- **Services**: Network layer for REST API communication.
- **Providers**: State management using the Provider package.
- **Features**: UI screens and feature-specific widgets.
- **Shared**: Common UI components used across multiple features.

### Backend Project (backend/)

A Node.js/Express.js API with PostgreSQL for data persistence.

- **Authentication**: JWT-based login/registration with bcrypt password hashing.
- **RBAC**: Role-based access control (Student vs Admin).
- **Entities**: Users, Menu Items, Orders, and Order Items.

## Detailed Steps

### Phase 1: Flutter Foundation
1.  **Update `pubspec.yaml`**: Add `http`, `shared_preferences`, `intl`.
2.  **Core Layer**: Define colors, strings, theme, and validators.
3.  **Models**: Implement `UserModel`, `MenuItemModel`, `CartItemModel`, and `OrderModel`.

### Phase 2: Logic and State
1.  **Services**: Implement `AuthService`, `MenuService`, and `OrderService`.
2.  **Providers**: Implement `AuthProvider`, `MenuProvider`, and `CartProvider`.

### Phase 3: UI Implementation
1.  **Shared Widgets**: `CustomButton`, `LoadingSpinner`, `ErrorDialog`.
2.  **Auth Feature**: Migration and cleanup of existing login/landing pages + registration/forgot password.
3.  **Menu Feature**: Student menu, admin add/edit items.
4.  **Cart & Home Features**: Cart management and home dashboard.

### Phase 4: Backend Implementation
1.  **Database**: Create `db_schema.sql` and `config/db.js`.
2.  **Auth**: Middleware and Auth Controller.
3.  **Features**: Menu and Order Controllers/Routes.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no linting or type errors.
- Test API endpoints using `curl` or a REST client (post-deployment).

### Manual Verification
- Verify navigation flow: Landing -> Login -> Home.
- Verify role-based UI: Admin sees add/edit buttons, Students see cart.
- Verify API connectivity: Mock or local backend testing.
