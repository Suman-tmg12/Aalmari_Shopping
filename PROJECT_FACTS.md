# Aalmari Shopping — Project Facts

This document records only features and configuration evidenced in the Aalmari_Shopping source code. It does not assume information not present in the repository. No passwords, database credentials, API keys, AWS credentials, or cryptographic keys are included.

## 1. Technology Stack

### Build and language

- Project artifact: `Aalmari_Application`
- Project version: `0.0.1-SNAPSHOT`
- Packaging: `WAR`
- Java: `21`
- Spring Boot: `3.2.5`
- Build tool: Apache Maven
- Final WAR name: `Aalmari_Application`

Source: `pom.xml`, lines 8–18 and 23–24.

### Libraries and frameworks

| Technology | Evidence and version |
|---|---|
| Spring Web / Spring MVC | Spring Boot `3.2.5` parent; version not repeated in `pom.xml` |
| Spring Data JPA / Hibernate | Spring Boot `3.2.5` parent; version not repeated in `pom.xml` |
| MySQL | `com.mysql:mysql-connector-j`; version is parent-managed and not stated in `pom.xml` |
| JSP | Embedded Tomcat Jasper: `org.apache.tomcat.embed:tomcat-embed-jasper`; version is parent-managed |
| JSTL API | `jakarta.servlet.jsp.jstl:jakarta.servlet.jsp.jstl-api:3.0.0` |
| JSTL implementation | `org.glassfish.web:jakarta.servlet.jsp.jstl:3.0.1` |
| Password hashing | `spring-security-crypto`; version is parent-managed; used for BCrypt |
| AWS S3 | `software.amazon.awssdk:s3:2.25.11` |
| HTML parsing | `org.jsoup:jsoup:1.17.2` |
| Development runtime | `spring-boot-devtools`; runtime scope; version is parent-managed |
| Spring scheduling | `@EnableScheduling` in the application entry class |

Source: `pom.xml`, lines 27–92.

### Dependency versions not explicitly declared

The following versions are not written in `pom.xml`; they are managed by the Spring Boot `3.2.5` parent: Spring Web, Spring Data JPA, MySQL Connector/J, Spring Security Crypto, Tomcat Embedded Jasper, DevTools, and the Spring Boot Maven Plugin.

## 2. Architecture

The application uses a Spring MVC, JSP, and JPA layered structure.

```text
JSP / JavaScript
       ↓
Controller
       ↓
Service / DTO
       ↓
Spring Data JPA Repository / JDBC Repository
       ↓
MySQL

Multipart upload / profile image processing
       ↓
S3 service
       ↓
AWS S3
```

### Package layout

| Package | Responsibility |
|---|---|
| `com.example.aalmari` | Contains the Spring Boot entry point |
| `com.example.aalmari.config` | Password encoder, remember-me interceptor/cookie, startup migration, AWS configuration |
| `com.example.aalmari.controller` | MVC page rendering, REST-style APIs, session checks, seller/admin endpoints |
| `com.example.aalmari.dto` | Request/display structures such as hero slides and login-related values |
| `com.example.aalmari.model` | JPA entities and a small number of plain Java product data classes |
| `com.example.aalmari.repository` | Spring Data JPA repositories and the raw JDBC hero-slide repository |
| `com.example.aalmari.service` | Interfaces and business services for cart, order, address, payment, S3, crypto, flash sales, notifications, and others |
| `com.example.aalmari.service.impl` | Implementations, including user operations and S3 operations |
| `com.example.aalmari.util` | Utility classes, including account-number masking |

### Important application classes

| Class | Role |
|---|---|
| `AalmariApplication` | Spring Boot entry point and scheduling enablement |
| `AccountController` | Registration, login, logout, and session setup |
| `CartController` / `CartApiController` | Cart page, count, add, update, and removal |
| `CheckoutController` | Address handling and checkout/order placement |
| `ProductController` | Product detail and verified-purchase reviews |
| `SellerController` | Seller application, dashboard, products, bank operations, and sales operations |
| `MyStoreController` | Public approved stores and store following |
| `SellerFlashSaleController` / `FlashController` | Seller flash-sale management and public flash-sale pages |
| `MyProfileController` | Profile information, avatar, and password updates |
| `OrderService` | Order creation and order-related persistence |
| `EsewaPaymentService` | eSewa form/status integration |
| `RememberMeService` | Persistent-login tokens and remember-me cookies |
| `CryptoService` | AES-GCM encryption/decryption of sensitive seller account data |
| `S3Service` | Seller, profile, product, and document upload handling |
| `AdminSalesController` | Sales summary API for the admin side |
| `SellerAccountMigrationRunner` | Startup migration of existing seller account numbers |

Relevant entry point: `src/main/java/com/example/aalmari/AalmariApplication.java`.

## 3. Database

The database URL, username, and password are supplied through environment placeholders. The actual database name is therefore not hard-coded in `application.properties` and cannot be stated factually from this project alone.

Hibernate uses `ddl-auto=update`. Database schema creation and alteration are not managed here by Flyway or Liquibase.

All JPA primary keys described below use `Long` with `GenerationType.IDENTITY` unless otherwise stated.

### `users`

Entity: `User`

| Java field | Java type | Database mapping / constraints |
|---|---|---|
| `id` | `Long` | Primary key, identity |
| `firstName` | `String` | `first_name`, required, length 100 |
| `lastName` | `String` | `last_name`, required, length 100 |
| `email` | `String` | `email`, required, unique, length 150 |
| `country` | `String` | `country`, required, length 100 |
| `phone` | `String` | `phone_number`, required, length 20 |
| `password` | `String` | `password`, required |
| `createdAt` | `LocalDateTime` | `created_at`, required, not updatable |
| `profilePicPath` | `String` | `profile_pic_path`, length 255 |

No role column or role relationship is declared.

### `user_addresses`

Entity: `Address`

- Primary key: `id`
- Foreign key: `user_id` → `users.id`, required, many-to-one and lazy
- Index: `idx_addr_user` on `user_id`
- Fields: `label` String(20), `receiverName` String(150), `phone` String(20), `province` String(50), `city` String(100), `street` String(255), `landmark` String(255), `is_default` Boolean, `created_at` LocalDateTime.

### `seller_documentation`

Entity: `SellerDocumentation`

- Primary key: `id`
- `userId`: `Long`, required and unique; stored as `user_id`, but no JPA `@ManyToOne` relationship to `User` is declared
- Store fields: `storeName` String(60), `storeTagline` String(120), `primaryCategory` String, `storeLogoPath` String, `storeBannerPath` String
- Contact fields: `businessEmail` String(254), `phoneNumber` String(20), `businessRegistrationNumber` String(200), `taxId` String(50)
- Documents: `docGovIdPath`, `docBizCertPath`, `docAddressProofPath`
- Bank fields: `accountHolder` String(60), `bankName` String(60), `accountIban` String(512), `accountIbanMasked` String(50)
- Status fields: `agreeTerms` Boolean, `status` String, `rejectionReason` String, `reviewedBy` Long, `reviewedAt` LocalDateTime
- Audit fields: `createdAt` LocalDateTime, `updatedAt` LocalDateTime

### `seller_products`

Entity: `SellerProduct`

- Primary key: `id`
- Foreign key: `seller_id` → `users.id`, required, many-to-one and lazy
- Unique field: `sku`
- Fields: `name` String, `category` String, `subCategory` String, `attributesJson` TEXT, `price` Integer, `discount` Integer, `stock` Integer, `sold` Integer, `active` Boolean, `approvalStatus` enum stored as String(20), `description` TEXT, `infoImageUrl` String(2048), `imageUrlsJson` TEXT
- Enum values: `PENDING`, `APPROVED`, `REJECTED`

### `cart_items`

Entity: `CartItem`

- Primary key: `id`
- Foreign key: `user_id` → `users.id`, required
- Foreign key: `product_id` → `seller_products.id`, required
- Unique constraint: `(user_id, product_id)`
- Fields: `quantity` Integer, default initialized to 1, `created_at` LocalDateTime

### `wishlist_items`

Entity: `WishlistItem`

- Primary key: `id`
- Foreign key: `user_id` → `users.id`, required
- Foreign key: `product_id` → `seller_products.id`, required
- Unique constraint: `(user_id, product_id)`
- Field: `created_at` LocalDateTime

### `orders`

Entity name: `ShopOrder`; entity class: `Order`

- Primary key: `id`
- Unique field: `order_number`, String(30)
- Foreign key: `user_id` → `users.id`, required
- One-to-many relationship: `OrderItem`, mapped by `order`, with cascade and orphan removal
- Fields: `status` String(30), `paymentMethod` String(20), `paymentStatus` String(20), `paymentReference` String(100), `transactionUuid` String(100) unique
- Money fields: `subtotal`, `discountAmount`, `deliveryFee`, and `total`, all `long`
- Delivery snapshot fields: `receiverName` String(150), `receiverPhone` String(20), `province` String(50), `city` String(100), `address` String(255), `landmark` String(255), `note` String(500)
- Audit field: `created_at` LocalDateTime

Documented values visible in source include order statuses `PLACED`, `PENDING_PAYMENT`, `CANCELLED`, `SHIPPED`, and `DELIVERED`; payment methods `COD`, `ESEWA`, `KHALTI`, and `CARD`; and payment statuses `UNPAID` and `PAID`.

### `order_items`

Entity: `OrderItem`

- Primary key: `id`
- Foreign key: `order_id` → `orders.id`, required
- Scalar field: `product_id`, required; no JPA relationship to `SellerProduct`
- Foreign key: `seller_id` → `users.id`, optional
- Index: `idx_oi_seller` on `seller_id`
- Fields: `name` String, `imageUrl` String(2048), `unitPrice` long, `originalPrice` long, `quantity` int, `lineTotal` long, `status` String(20), `deliveredAt` LocalDateTime
- Documented status values include `PENDING`, `CONFIRMED`, `SHIPPED`, `DELIVERED`, and `CANCELLED`

### `payments`

Entity: `Payment`

- Primary key: `id`
- Foreign key: `order_id` → `orders.id`, required
- Fields: `provider` String(20), `transactionUuid` String(100), `transactionCode` String(100), `status` String(30), `amount` long, `rawResponse` TEXT, `createdAt` LocalDateTime

### `remember_me_tokens`

Entity: `RememberMeToken`

- Primary key: `id`
- Foreign key: `user_id` → `users.id`, required, many-to-one and lazy
- Fields: `tokenHash` String(64) required and unique, `expiresAt` LocalDateTime required, `createdAt` LocalDateTime required

Only an SHA-256 representation of the remember-me token is stored.

### `customer_notifications`

Entity: `CustomerNotification`

- Primary key: `id`
- Foreign key: `user_id` → `users.id`, required
- Fields: `title` String(120), `message` String(300), `audience` String(16), `orderId` Long, `createdAt` LocalDateTime, `readAt` LocalDateTime
- Audience default in source: `CUSTOMER`
- Indexes: `(user_id, created_at)` and `(user_id, read_at)`

### `flash_sales`

Entity: `FlashSale`

- Primary key: `id`
- Foreign key: `seller_id` → `users.id`, required
- Fields: `name` String(60), `startTime` long epoch milliseconds, `endTime` long epoch milliseconds, `endedEarly` Boolean, `createdAt` long epoch milliseconds
- One-to-many relationship: `FlashSaleItem`, cascade all and orphan removal

### `flash_sale_items`

Entity: `FlashSaleItem`

- Primary key: `id`
- Foreign key: `flash_sale_id` → `flash_sales.id`, required
- Foreign key: `product_id` → `seller_products.id`, required
- Index: `idx_fsi_product` on `product_id`
- Fields: `regularPrice` int, `discount` int, `flashPrice` int, `qty` int, `limitPerCustomer` int, `sold` int

### `flash_purchases`

Entity: `FlashPurchase`

- Primary key: `id`
- Foreign key: `item_id` → `flash_sale_items.id`, required
- Scalar field: `user_id` Long, required
- Fields: `qty` int, `createdAt` long epoch milliseconds
- Index: `(user_id, item_id)`

### `product_reviews`

Entity: `ProductReview`

- Primary key: `id`
- Foreign key: `user_id` → `users.id`, required
- Foreign key: `product_id` → `seller_products.id`, required
- Unique constraint: `(user_id, product_id)`
- Index: `idx_review_product` on `product_id`
- Fields: `rating` int required, `comment` String(1000) required, `verifiedPurchase` Boolean required, `createdAt` LocalDateTime, `updatedAt` LocalDateTime

### `store_follows`

Entity: `StoreFollow`

- Primary key: `id`
- Foreign key: `follower_id` → `users.id`, required
- Foreign key: `seller_id` → `users.id`, required
- Unique constraint: `(follower_id, seller_id)`
- Index: `idx_store_follow_seller` on `seller_id`
- Field: `created_at` LocalDateTime

### `store_messages`

Entity: `StoreMessage`

- Primary key: `id`
- Foreign key: `customer_id` → `users.id`, required
- Foreign key: `seller_id` → `users.id`, required
- Foreign key: `product_id` → `seller_products.id`, required
- Foreign key: `sender_id` → `users.id`, required
- Fields: `subject` String(120), `body` String(2000), `unreadForSeller` Boolean, `unreadForCustomer` Boolean, `createdAt` LocalDateTime
- Indexes: `idx_msg_seller` on `seller_id` and `idx_msg_customer` on `customer_id`

### `payout_settlements`

Entity: `PayoutSettlement`

- Primary key: `id`
- Scalar field: `seller_id` Long, required; no JPA relationship to `User`
- Fields: `period` String(20), `status` String(20), `reference` String(100), `settledAt` LocalDateTime

### `marketplace_settings`

Entity: `MarketplaceSetting`

- Primary key: `setting_key`, String(64)
- `setting_value`: String(80), required
- Source constant: platform-name key and default value
- No JPA relationship

### `hero_slides`

This table is not mapped as a JPA entity. `HeroSlideRepository` reads it using raw SQL.

Evidence-based visible columns:

- `id`
- `active`
- `cta_text`
- `cta_url`
- `image_url`
- `priority`
- `subtitle`
- `title`

Exact MySQL data types and constraints for this table are not declared in a JPA entity or migration file.

Source: `src/main/java/com/example/aalmari/repository/HeroSlideRepository.java`.

### Plain, non-JPA model classes

- `Product`: plain Java class for product display data.
- `FlashProduct`: plain Java class for flash-sale display data.

These classes are not database tables.

## 4. Features by Role

### Visitor

| Feature | Status | Evidence |
|---|---|---|
| Homepage and hero slider | Implemented | `HomeController` and `HeroSlideRepository` |
| Browse categories | Implemented | `CategoriesController` |
| Search products | Implemented | `SearchResultController` |
| View product detail | Implemented | `ProductController` |
| View public approved store | Implemented | `MyStoreController` |
| View flash sales | Implemented | `FlashController` |
| View static information pages | Implemented | About, Careers, Contact, Legal, and Support controllers |
| Registration | Implemented | `AccountController` |

### Logged-in user/customer

| Feature | Status | Evidence |
|---|---|---|
| Login/logout | Implemented | Session-based `AccountController` |
| Remember-me login | Implemented | `RememberMeService`, remember-me entity and interceptor |
| Profile details | Implemented | `MyProfileController` |
| Avatar upload/removal | Implemented | `MyProfileController` and profile S3 service |
| Password change | Implemented | `MyProfileController` |
| Address add/edit/delete/default | Implemented | `CheckoutController` and `AddressService` |
| Cart add/update/remove/count | Implemented | Cart MVC and API controllers |
| Wishlist add/remove/list | Implemented | `WishlistApiController` |
| Buy-now/cart checkout | Implemented | `CheckoutController` |
| COD order | Implemented | Checkout/order placement source |
| eSewa order | Partial | Form/status integration exists; callback behavior is not fully documented by repository tests |
| Khalti payment | Not implemented | No source checkout implementation found; source rejects it at placement |
| Card payment | Not implemented | No source checkout implementation found; source rejects it at placement |
| Product review | Implemented with rule | Login required; source checks that the user has a delivered matching order item |
| Follow store | Implemented | `MyStoreController` |
| Store messaging | Implemented | `StoreMessageController` |
| Notifications | Implemented | `CustomerNotificationController` |

### Seller

| Feature | Status | Evidence |
|---|---|---|
| Seller application | Implemented | `SellerController` and `SellerDocumentation` |
| S3 document/logo/banner upload | Implemented | `SellerController` and S3 service |
| Pending/rejected/approved status | Implemented | `SellerDocumentation.status` |
| Approved public store | Implemented | Public store route checks seller status |
| Seller dashboard | Implemented | `SellerController` and `SellerDashboard.jsp` |
| Add/update/delete seller products | Implemented | Seller product APIs/controller methods |
| Product approval status field | Implemented | `SellerProduct.approvalStatus` |
| Activate/deactivate product | Implemented | Seller product controller |
| Flash-sale create/end/delete | Implemented | `SellerFlashSaleController` |
| Seller order status update | Implemented | Seller order APIs |
| Seller store messages | Implemented | `StoreMessageController` |
| Seller notifications | Implemented | `SellerNotificationController` |
| Seller finance/payout views | Partial | Payout settlement model and seller-finance routes exist; external settlement is not verified |
| Complete external payouts | Partial | Settlement records and status exist, but no bank transfer provider integration is evidenced |

### Admin

| Feature | Status | Evidence |
|---|---|---|
| Sales summary API | Implemented only as an API | `AdminSalesController`; no authorization check exists |
| Protected seller-bank reveal endpoint | Partial | `SellerController` checks an `isAdmin` session attribute |
| Seller application approval/rejection | Partial in shopping project | Status fields and public-store filtering exist, but no complete review controller/admin dashboard was found |
| Product moderation | Partial/Not implemented | `approvalStatus` exists and repository methods filter it, but no complete admin moderation workflow is present in the shopping project |
| Formal admin login | Not implemented | No Spring Security admin login or persisted admin role found in this project |
| Formal admin role model | Not implemented | `User` has no role or authority fields |
| Admin route authorization | Not implemented | No Spring Security filter chain or role annotations found |

## 5. Security

### Login

- Registration validates required fields and terms acceptance.
- Passwords must contain at least eight characters in the registration source.
- Email lookup is case-insensitive for login.
- BCrypt verifies the stored password and encoded passwords are stored.
- Successful login creates HTTP session attributes including `userId` and profile fields.
- Logout invalidates the session and removes remember-me state.

### Password encoding

- BCrypt is configured through `PasswordEncoderConfig` using Spring Security Crypto.
- Password migration/role migration is not implemented as a role-based framework.

### Remember-me

- A 32-byte random token is Base64URL encoded.
- Only the SHA-256 hash is stored in `remember_me_tokens`.
- Tokens expire after 30 days.
- The cookie is HTTP-only and scoped to `/`.
- The cookie is set with `Secure=false`; the source contains a note to enable it when HTTPS is used.
- `RememberMeConfig` restores the HTTP session for a valid token.

### Role and route protection

- Authorization is mostly implemented using direct session checks for `userId`.
- Seller ownership is checked for some product update, delete, and order operations.
- No Spring Security filter chain or `SecurityFilterChain` was found.
- No `PreAuthorize`, `hasRole`, or `hasAuthority` usage was found.
- No role column or role enum exists on `User`.
- An `isAdmin` session attribute gates one seller-bank reveal endpoint, but the shopping project does not evidence a complete verified admin login or role assignment.
- `GET /api/admin/sales/summary` does not contain an authorization check in `AdminSalesController`.

### Seller account migration

`SellerAccountMigrationRunner` runs on application startup and:

- expands the account/IBAN column for existing data;
- creates or updates an account-mask column;
- converts legacy plain account numbers to encrypted values;
- creates masked account values.

The migration also handles values already in the encrypted format and avoids unsafe re-encryption. Seller account decryption compatibility depends on a matching external cryptographic configuration.

## 6. Images and File Handling

### Multipart limits

- Maximum individual uploaded file: `10MB`
- Maximum complete multipart request: `60MB`

### S3 configuration names visible in code

- AWS region: `ap-southeast-2`
- Seller/document S3 bucket property is configured
- Profile-photo S3 bucket property is configured
- Product-image S3 bucket property is configured

Bucket values themselves are represented as configuration properties and are not repeated as credentials or secrets in this facts file.

### Profile image handling

- Maximum profile image size: `2MB`
- Accepted types: JPEG, PNG, GIF, and WebP
- The image is resized/cropped to `512 × 512` pixels and converted to JPEG
- Profile images use the profile S3 bucket

### Seller uploads

Seller document, logo, and banner uploads use UUID-based keys with this source path pattern:

```text
sellers/{userId}/{folder}/{UUID}.{extension}
```

### Product uploads

Product image keys use UUID-based names and are placed in the product-image bucket.

### General file handling limitations

- No global, explicit per-file format allowlist was found for every seller/product document upload.
- Multipart limits are enforced by Spring configuration.
- The profile image service has the strongest validation and image-conversion checks.

## 7. Main JSP Pages and Controllers

| Page / URL | JSP | Backing controller |
|---|---|---|
| `/` | `welcome.jsp` | `HomeController` |
| `/signin` | `auth/signin.jsp` | `AccountController` |
| `/register` | Redirect to login on success | `AccountController` |
| `/login` | `auth/login.jsp` | `AccountController` |
| `/welcome` | `welcome.jsp` | `AccountController` |
| `/logout` | Redirect/logout action | `AccountController` |
| `/myprofile` | `myprofile.jsp` | `MyProfileController` |
| `/cart` | `cart.jsp` | `CartController` |
| `/checkout` | `checkout.jsp` | `CheckoutController` |
| `/checkout/success` | `order-success.jsp` | `CheckoutController` |
| `/product/{id}` | `productDetail.jsp` | `ProductController` |
| `/category` | `categories.jsp` | `CategoriesController` |
| `/search...` | `searchResult.jsp` | `SearchResultController` |
| `/flash` | `flash.jsp` | `FlashController` |
| `/flashsaleproduct/{id}` or flash route | `flashsaleproduct.jsp` | `FlashController` |
| `/seller` | `SellerPage/seller.jsp` | `SellerController` |
| `/SellerDashboard` | `SellerPage/SellerDashboard.jsp` | `SellerController` |
| `/mystore` | `mystore.jsp` | `MyStoreController` |
| `/store/{sellerId}` | `mystore.jsp` | `MyStoreController` |
| `/AboutUs` | `AboutUs.jsp` | `AboutUsController` |
| `/Careers` | `Careers.jsp` | `CareersController` |
| `/ContactUs` | `ContactUs.jsp` | `ContactUsController` |
| `/support`, `/helpcenter`, `/help-center`, `/help` | `support.jsp` | `CustomerSupportController` |
| `/legal/{document}` | `legal.jsp` | `LegalController` |
| eSewa redirect/return view | `esewa-redirect.jsp` | eSewa controller/service flow |

Reusable JSP components include:

- `header.jsp`
- `footer.jsp`
- `Slider.jsp`
- `product.jsp`
- `tabbarlogoimages.jsp`

## 8. Application Configuration

Non-secret configuration visible in `src/main/resources/application.properties`:

| Setting | Configured value |
|---|---|
| Server port | `8080` |
| Session cookie name | `AALMARI_SHOPPING_SESSION` |
| JSP prefix | `/WEB-INF/views/` |
| JSP suffix | `.jsp` |
| Database URL | Environment variable resolved |
| Database username | Environment variable resolved |
| Database password | Environment variable resolved |
| JDBC driver | `com.mysql.cj.jdbc.Driver` |
| Hibernate DDL mode | `update` |
| SQL logging | Disabled |
| Hibernate dialect | `MySQL8Dialect` |
| AWS region | `ap-southeast-2` |
| Seller/document bucket | Configuration property; value comes from source configuration |
| Profile bucket | Configuration property; value comes from source configuration |
| Product bucket | Configuration property; value comes from source configuration |
| Individual upload limit | `10MB` |
| Multipart request limit | `60MB` |
| eSewa product code | Test product code configured |
| eSewa form URL | eSewa test form endpoint |
| eSewa status URL | eSewa test status endpoint |
| eSewa success URL | `http://localhost:8080/payment/esewa/success` |
| eSewa failure URL | `http://localhost:8080/payment/esewa/failure` |

The source also contains environment placeholders for AWS credentials and a cryptographic key, but their values are intentionally omitted from this report.

## 9. Automated Tests

- No `src/test` directory or Java test source files were found.
- No JUnit, Spring Test, or Mockito dependency was declared in `pom.xml`.
- No test classes or automated test suite were found.
- Therefore, there is no source-evidenced automated test coverage for this project.

## 10. Known Limitations and Incomplete Areas

1. **No formal role model**: `User` has no role field and no Spring Security authorities.
2. **No centralized security filter chain**: route protection is mostly manual session checking.
3. **Admin authorization is incomplete**: some admin endpoints rely on session flags or have no authorization at all.
4. **Seller approval UI is incomplete**: status and public-store filtering exist, but the shopping project does not contain a complete seller-review/admin workflow.
5. **Product moderation is incomplete**: product approval status exists, but a complete admin moderation workflow is not evidenced.
6. **Payment completeness is limited**: COD and eSewa integration are present; Khalti and card are rejected or not implemented. Callback behavior lacks an automated test suite.
7. **External payouts are incomplete**: payout records and status fields exist, but no provider-based money-transfer integration is evidenced.
8. **No migration framework**: schema changes use `hibernate.ddl-auto=update`; there is no Flyway or Liquibase evidence.
9. **Remember-me security**: the cookie is HTTP-only, but secure-cookie behavior is disabled in source and must be enabled under HTTPS.
10. **Upload validation is uneven**: profile images have strong type/size processing; no comparable complete validation was found for every seller and product upload.
11. **Database name cannot be confirmed**: `application.properties` resolves the database URL from an environment variable.
12. **Exact `hero_slides` schema cannot be confirmed**: no JPA entity or SQL migration in this project defines all MySQL types and constraints.
13. **No automated tests**: business logic, controllers, payments, security, and S3 behavior are not covered by source-evidenced test code.

## 11. Main User Flows

### Browse and search

1. A visitor opens `/`.
2. `HomeController` loads homepage data and active hero slides.
3. Categories are opened through `/category` or product category links.
4. Search enters a controller that queries seller products and renders `searchResult.jsp`.
5. The visitor opens `/product/{id}` to view product detail.
6. The detail page can show similar products, reviews, flash status, and purchase-related information.

### Cart

1. A logged-in customer adds a product through the cart API or MVC action.
2. `CartItem` stores the customer, product, and quantity.
3. `/cart` loads the customer's items.
4. The customer updates quantity or removes an item.
5. Cart count is available through the cart API.

### Checkout and order

1. The customer chooses checkout or buy-now.
2. `CheckoutController` loads or saves addresses.
3. The customer selects COD or eSewa as an implemented payment option.
4. The checkout action validates the session, addresses, stock, and order state.
5. `OrderService` creates an order and order items.
6. Address and seller data are copied into the order snapshot.
7. Stock and sold values are updated.
8. Payments are recorded when applicable.
9. Cart items are cleared.
10. The customer is redirected to `order-success.jsp` or an eSewa redirect flow.

### Seller product management

1. The logged-in user submits the seller application and required files.
2. Seller documentation is stored with a pending status.
3. The public store is visible only under the status rules implemented in source.
4. An approved seller opens the seller dashboard.
5. The seller creates or updates a product with SKU, price, stock, category, description, attributes, and images.
6. Product approval status is stored on `SellerProduct`.
7. The seller can activate/deactivate or delete owned products.
8. The seller can create flash-sale entries for owned products.

### Seller order management

1. A customer places an order containing one or more seller products.
2. Each order line stores a seller ID and status.
3. The seller views assigned order items.
4. The seller updates item status to the supported workflow values.
5. A delivered status records the delivery time.

### Profile and store community

1. A logged-in customer opens `/myprofile`.
2. The customer can update text fields and password.
3. The profile image is uploaded, resized, converted, and stored in S3.
4. The customer can follow a seller store.
5. The customer can send store messages and read message threads.
6. Sellers can reply and view unread message counts.

### Admin moderation flow visible in this project

The following flow is only partially evidenced:

1. Seller documentation and status are stored in `seller_documentation`.
2. Public-store and product code contains approval-status checks.
3. The shopping project exposes selected sales summary and sensitive-bank endpoints.
4. No complete seller-approval or product-moderation interface/controller workflow is present in this project source.

## 12. Source Reference Summary

- `pom.xml`
- `src/main/resources/application.properties`
- `src/main/java/com/example/aalmari/AalmariApplication.java`
- `src/main/java/com/example/aalmari/model/`
- `src/main/java/com/example/aalmari/controller/`
- `src/main/java/com/example/aalmari/service/`
- `src/main/java/com/example/aalmari/service/impl/`
- `src/main/java/com/example/aalmari/repository/`
- `src/main/java/com/example/aalmari/config/`
- `src/main/webapp/WEB-INF/views/`

