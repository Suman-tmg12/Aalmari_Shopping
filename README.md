# Aalmari Shopping

Aalmari Shopping is a full-stack Java ecommerce marketplace built with Spring Boot, Spring MVC, JSP, JPA/Hibernate, MySQL, JavaScript, and AWS S3. It supports customer shopping, cart and wishlist management, COD checkout, saved addresses, seller onboarding and verification, seller product management, flash sales, order processing, and seller finance summaries.

> The current README is an AI-maintainer context guide, not a record of the original login demo.

## Technology Stack

- Java 21
- Spring Boot 3.2.5
- Spring MVC
- Spring Data JPA / Hibernate
- MySQL
- JSP, JSTL, HTML5, CSS3, JavaScript
- Maven Wrapper
- BCrypt password hashing
- AWS SDK for Java v2 / Amazon S3
- Embedded Tomcat packaged as a WAR
- Spring Boot DevTools

## Run the Project

### Prerequisites

- JDK 21
- MySQL
- Maven wrapper (`mvnw.cmd` is included)
- AWS credentials only when S3 upload/presigned-profile features are used

### Environment Variables

Configure MySQL and AWS values as environment variables:

```powershell
# Confirmed local database for this project
$env:aalmari_database_url="jdbc:mysql://localhost:3306/aalmari_shopping"
$env:aalmari_database_username="root"
$env:aalmari_database_password="your-mysql-password"

# Required for private S3 uploads and presigned profile URLs
$env:AWS_ACCESS_KEY_ID="your-rotated-access-key"
$env:AWS_SECRET_ACCESS_KEY="your-rotated-secret-key"
```

The AWS credential pair that was previously shared publicly must be revoked and replaced. Never commit credentials or place them in `application.properties`.

The application uses these AWS settings:

```properties
aws.region=ap-southeast-2
aws.s3.bucket=sellerimages123
aws.s3.profileBucket=aalmari-profile-pic
aws.s3.productImages=aalmari-product-images
```

### Start

Windows:

```powershell
.\mvnw.cmd spring-boot:run
```

Linux/macOS:

```bash
./mvnw spring-boot:run
```

Open:

```text
http://localhost:8080
```

JSP support means the application should be run with `spring-boot:run` rather than relying on an executable JAR.

---

# AI System Context

## 1. Persona and Domain

When modifying this project, act as an expert Spring MVC/ecommerce engineer. Preserve the existing package boundaries, route contracts, JSP model attributes, session authentication conventions, JPA mappings, and transactional business rules.

The application is a marketplace rather than a single-seller shop:

- Users can browse, search, register, authenticate, and purchase products.
- Sellers can submit documentation and manage products and flash sales.
- Products belong to sellers.
- Orders contain immutable product and address snapshots.
- Cart quantity changes, stock changes, flash claims, and checkout are transaction-sensitive.
- Checkout currently implements Cash on Delivery (COD). Do not advertise or enable other payment methods unless the payment flow is fully implemented.

## 2. Architecture and Request Lifecycle

```text
JSP / HTML / JavaScript
        |
        v
Spring MVC Controller or @RestController
        |
        v
Service (@Transactional where state is changed)
        |
        v
Spring Data JPA Repository
        |
        v
Hibernate
        |
        v
MySQL
        |
        v
Redirect / JSP Model / JSON Response
```

### MVC page flow

1. A JSP link or form sends a browser request.
2. A `@Controller` handles `GET` or `POST`.
3. The controller obtains user identity from `HttpSession` when required.
4. It calls a service or repository.
5. JPA repositories read or mutate MySQL entities.
6. The controller adds attributes to `Model` or redirects.
7. Spring resolves JSP names using:

```text
Prefix: /WEB-INF/views/
Suffix: .jsp
```

For example, returning `"checkout"` renders:

```text
/WEB-INF/views/checkout.jsp
```

### AJAX/JSON flow

1. JavaScript sends `fetch()` or form data to an `/api/**` endpoint.
2. `@RestController` or `@ResponseBody` receives the request.
3. Session identity is resolved by the controller or service.
4. State is returned as `ResponseEntity`, JSON maps, or DTOs.
5. JavaScript updates the page or performs a redirect.

### Authentication state

The project does not use a Spring Security filter chain. It uses `HttpSession`:

- `userId`
- `userFirstName`
- `userLastName`
- `userEmail`
- `userPhone`
- `userProfilePicPath`

Controller code should obtain identity from the session rather than trusting a `userId` request parameter. `/logout` invalidates the session.

## 3. Project Directory Map

```text
src/main/java/com/example/aalmari/
├── AalmariApplication.java
├── config/
│   ├── PasswordEncoderConfig.java
│   └── S3Config.java
├── controller/
│   ├── AccountController.java
│   ├── HomeController.java
│   ├── ProductController.java
│   ├── CategoriesController.java
│   ├── SearchResultController.java
│   ├── SearchSuggestController.java
│   ├── CartController.java
│   ├── CartApiController.java
│   ├── WishlistApiController.java
│   ├── CheckoutController.java
│   ├── MyProfileController.java
│   ├── MyStoreController.java
│   ├── SellerController.java
│   ├── SellerFlashSaleController.java
│   ├── FlashController.java
│   └── static-page and model-advice controllers
├── dto/
├── model/
├── repository/
└── service/
    └── impl/

src/main/resources/
├── application.properties
└── static/
    ├── css/
    └── js/

src/main/webapp/
├── HomePageImages/
├── Products/
├── FlashSaleImages/
├── SliderImages/
├── logoImages/
└── WEB-INF/
    ├── components/
    └── views/
```

### Core configuration classes

- `AalmariApplication`: Spring Boot entry point.
- `PasswordEncoderConfig`: exposes a BCrypt `PasswordEncoder` bean.
- `S3Config`: creates AWS S3 client and presigner beans.

### Main controller responsibilities

| Controller | Responsibilities |
|---|---|
| `AccountController` | Sign-in page, registration, login, session setup, logout |
| `HomeController` | Homepage, hero slides, active products |
| `ProductController` | Product detail, JSON attribute/gallery parsing, related products |
| `CategoriesController` | Category browsing |
| `SearchResultController` | Search result page |
| `SearchSuggestController` | Search autocomplete endpoint |
| `CartController` | Cart page and form-based updates/removal |
| `CartApiController` | AJAX cart mutation/count |
| `WishlistApiController` | Wishlist IDs/add/remove |
| `CheckoutController` | Checkout, address management, COD order placement |
| `MyProfileController` | User profile and order/wishlist presentation |
| `MyStoreController` | Public/seller store pages |
| `SellerController` | Seller onboarding, dashboard, product CRUD, seller orders |
| `SellerFlashSaleController` | Save/end/delete flash sales |
| `FlashController` | Live flash-sale pages |

Shared model attributes are also supplied by `HeaderProfileAdvice` and `HomeFlashAdvice`.

### Services and repositories

The service package contains:

- `UserService` / `UserServiceImpl`
- `CartService`
- `WishlistService`
- `AddressService`
- `OrderService`
- `FlashSaleService`
- `S3Service`

The repository package contains Spring Data JPA repositories for users, seller documentation, products, cart items, wishlist items, addresses, orders, order items, flash sales, flash-sale items, flash purchases, and hero slides.

### JSP structure

Primary views include:

```text
welcome.jsp
auth/login.jsp
auth/signin.jsp
categories.jsp
searchResult.jsp
productDetail.jsp
flash.jsp
flashsaleproduct.jsp
cart.jsp
checkout.jsp
order-success.jsp
myprofile.jsp
mystore.jsp
SellerPage/seller.jsp
SellerPage/SellerDashboard.jsp
AboutUs.jsp
Careers.jsp
ContactUs.jsp
support.jsp
```

Reusable components include `header.jsp`, `footer.jsp`, `Slider.jsp`, `product.jsp`, and `tabbarlogoimages.jsp`. Static CSS/JavaScript belongs under `src/main/resources/static/`.

## 4. Database Schema and Entity Relationships

Hibernate uses `spring.jpa.hibernate.ddl-auto=update`. Entity schema details should be preserved when changing classes.

### `users`

- Primary key: `id` (`BIGINT`)
- Unique: `email`
- Fields: first name, last name, country, phone number, BCrypt password, creation time, profile picture path

### `seller_documentation`

- Table: `seller_documentation`
- Unique scalar `user_id`
- Store identity and category
- Logo/banner and verification document paths
- Business registration and tax information
- Bank account details
- Agreement flag
- Status such as `pending` or `rejected`
- Rejection reason, reviewer ID/time, and audit timestamps

This entity stores a `userId`; it is not mapped with `@ManyToOne` in the same way as `SellerProduct` and cart/address entities.

### `seller_products`

- Table: `seller_products`
- Primary key: `id`
- Many-to-one seller `User` through `seller_id`
- Name, SKU, category, subcategory
- JSON attributes text
- JSON image URL list text
- Price, discount, stock, sold count
- Active flag
- Description and informational image URL

Customer discount price is normally calculated from:

```text
(price * (100 - discount)) / 100
```

Only active products should be shown in customer-facing workflows.

### `cart_items`

- Table: `cart_items`
- Many-to-one `User`
- Many-to-one `SellerProduct`
- Unique pair: `(user_id, product_id)`
- Quantity
- Creation timestamp
- Quantity limits include `10`, stock, and flash-sale eligibility

### `wishlist_items`

- Table: `wishlist_items`
- Many-to-one `User`
- Many-to-one `SellerProduct`
- Unique pair: `(user_id, product_id)`

### `user_addresses`

- Table: `user_addresses`
- Many-to-one `User`
- Label, receiver name, phone, province, city, street, landmark
- Default-address flag
- Creation timestamp

There should normally be only one default address per user.

### `orders`

The Java entity is named `Order`/`ShopOrder` depending on the package implementation to avoid the SQL reserved word, and it maps to `orders`.

- Primary key: `id`
- Many-to-one `User`
- Unique order number
- Status
- Payment method and payment status
- Subtotal, discount, delivery fee, total
- Delivery receiver/address snapshot
- Note and creation timestamp

### `order_items`

- Table: `order_items`
- Many-to-one parent order
- Seller `User` relationship
- Copied product ID
- Copied product name and image
- Unit price and original price
- Quantity and line total
- Seller line status
- Delivery timestamp

Seller-visible status values are:

```text
PENDING
CONFIRMED
SHIPPED
DELIVERED
CANCELLED
```

### `flash_sales`

- Many-to-one seller `User`
- Name
- Start/end epoch milliseconds
- Ended-early flag
- Creation timestamp
- One-to-many flash-sale items

### `flash_sale_items`

- Many-to-one flash sale
- Many-to-one seller product
- Regular price snapshot
- Discount percentage
- Flash price
- Flash quantity
- Per-customer limit
- Sold quantity

### `flash_purchases`

- Many-to-one flash-sale item
- User ID
- Quantity
- Creation timestamp

This tracks customer flash-sale claims and is used with flash quantity/customer limits.

### Relationship Summary

```text
User ─< SellerDocumentation
User ─< SellerProduct
User ─< CartItem >─ SellerProduct
User ─< WishlistItem >─ SellerProduct
User ─< Address
User ─< Order ─< OrderItem
User ─< FlashSale ─< FlashSaleItem
SellerProduct ─< FlashSaleItem ─< FlashPurchase
User(seller) ─< OrderItem
```

## 5. Coding and Data Conventions

### Dependency injection

Both constructor injection and legacy field injection exist. For new code, use constructor injection with `final` fields. Preserve existing style in a targeted edit rather than performing an unrelated style migration.

### Transactions

Use `@Transactional(readOnly = true)` for reads and `@Transactional` for cart, address, stock, flash-purchase, order, and seller mutations.

Checkout must remain atomic across:

- Cart validation
- Address ownership validation
- Stock validation
- Flash purchase claims
- Stock decrement
- Sold-count increment
- Order and order-line creation
- Cart clearing

### JSON text fields

Use Jackson `ObjectMapper` for:

- `SellerProduct.attributesJson`
- `SellerProduct.imageUrlsJson`

Do not assume these are normal relational columns or that the stored data is always a complete URL.

### S3 image handling

S3 is used for:

- User profile photos
- Seller logos and banners
- Seller verification documents
- Product images

Stored values may be relative keys or complete HTTP(S) URLs. Normalize presentation URLs consistently, for example:

- Relative key: prepend the configured S3 bucket URL
- Absolute URL: preserve it

### Exceptions and HTTP responses

There is no repository-wide global exception handler. Existing code commonly uses:

- Missing login: redirect to `/login` or HTTP `401`
- Ownership/security failure: HTTP `403`
- Invalid argument or quantity: HTTP `400`
- Unexpected server failure: HTTP `500`
- Business redirect failure: flash error plus redirect

Add local handling that matches the existing controller/view or JSON contract. Do not return raw password or BCrypt hash data.

### JSP conventions

Controllers use `Model` or `ModelAndView`. Update the controller and JSP together when adding or renaming attributes.

Use the project context path in links:

```jsp
${pageContext.request.contextPath}
```

Follow JSTL imports and script escaping already used by the target JSP. Static assets belong in `src/main/resources/static/`.

## 6. Core Business Workflows

### Registration and login

`AccountController` → `UserService/UserServiceImpl` → `UserRepository` → `users`

1. Collect registration fields and terms consent.
2. Validate required fields and password length.
3. Reject duplicate email.
4. Hash password with BCrypt.
5. Save the user.
6. Login validates email and password.
7. Populate session identity attributes.

### Product discovery

`HomeController`, `CategoriesController`, `SearchResultController`, `SearchSuggestController`, and `ProductController` → `SellerProductRepository` → `seller_products`

1. Homepage loads active products and hero-slide data.
2. Category/search pages filter active products.
3. Search suggestions return matching names.
4. Product details parse JSON attributes/gallery data.
5. The product page calculates and displays flash-aware pricing and stock.
6. Similar products are resolved from subcategory/category.

### Cart and wishlist

Cart controllers/services/repositories:

- `CartService`
- `CartItemRepository`
- `SellerProductRepository`
- `CartItem` / `SellerProduct`

Wishlist uses `WishlistService`, `WishlistItemRepository`, and `WishlistItem`.

Cart behavior includes:

- Maximum quantity `10`
- Stock limits
- Active-product validation
- Live flash pricing
- Flash remaining quantity and per-customer limits
- Idempotent wishlist add/remove

### Checkout and COD orders

`CheckoutController` → `AddressService` → `CartService` → `OrderService` → JPA repositories

1. Require an authenticated user and nonempty cart.
2. Load saved addresses and optional default address.
3. Validate recipient/address input.
4. Validate cart quantities and flash limits.
5. Create order and order-item snapshots.
6. Apply delivery and line totals.
7. Generate the order number format `AAL-%06d`.
8. Clear cart items.
9. Redirect to `/checkout/success?orderId=...`.

Address ownership must be verified before placement or editing.

### Seller onboarding

`SellerController` → `SellerDocumentationRepository` → `S3Service` → `seller_documentation`

1. Require login.
2. Collect store, verification, and bank data.
3. Upload logo/banner and verification files to S3.
4. Save or update documentation.
5. Set status to pending unless the current business flow explicitly rejects/resubmits.
6. Only approved/eligible sellers should receive product and dashboard capabilities.

### Seller product management

`SellerController` → `SellerProductRepository` / `S3Service` → `seller_products`

Seller operations include:

- Create and update product
- Upload/delete product images
- Parse/store category attributes as JSON
- Toggle active state
- Delete products only when no blocking live/scheduled flash-sale usage remains
- Verify seller ownership before every mutation

### Flash sales

`SellerFlashSaleController` / `FlashController` / `FlashSaleService` → flash-sale entities

1. Seller saves a named sale with start/end epoch milliseconds.
2. Sale items specify flash price, quantity, discount, and customer limit.
3. Public pages display live flash deals.
4. Cart and checkout calculate and validate live flash quantities.
5. Checkout transactionally records a `FlashPurchase` claim.

### Seller orders and finance

`SellerController` / `OrderService` use order items to:

- Identify lines belonging to the logged-in seller
- Group seller line cards by parent order
- Update line status: pending, confirmed, shipped, delivered, or cancelled
- Generate finance totals and seller summaries

Never allow a seller to update another seller's order line.

## 7. AI Assistant Rules

1. Preserve MVC separation: HTTP handling in controllers, business rules in services, persistence in repositories, records in entities, API/page projections in DTOs.
2. Read identity from `HttpSession`; never use a browser-supplied `userId` as authorization.
3. Verify ownership for sellers, cart rows, wishlist rows, addresses, products, documentation, and order lines.
4. Use constructor injection for new components; preserve existing style if unrelated to the task.
5. Use `@Transactional` for operations that change multiple entities or inventory.
6. Keep cart, stock, flash, and checkout limits enforced together.
7. Never expose passwords or password hashes.
8. Keep only active products in customer-facing listings.
9. Preserve order/address/product snapshots instead of joining mutable data into historical orders.
10. Keep JSP attribute names synchronized with their controller.
11. Keep route methods and view names synchronized with JSP links/forms.
12. Use JSON parsing for `attributesJson` and `imageUrlsJson`.
13. Normalize S3 keys and absolute HTTP(S) URLs carefully.
14. Preserve COD as the implemented payment method unless adding real payment integration.
15. For entity changes, update table/column mappings, repositories, services, controllers, DTO projections, and JSP assumptions together.
16. Return consistent API outcomes:
    - `401`: unauthenticated
    - `403`: authenticated but unauthorized
    - `400`: invalid input or business state
    - `500`: unexpected server error
17. Before changing coupled checkout, cart, flash, order, or seller logic, inspect the owning service and repository first.

## Verified Current State

- `JAVA_HOME` should be `C:\Program Files\Java\jdk-21.0.10` or another JDK 21 installation directory, never the `bin` directory.
- Local MySQL service: `MySQL80`, port `3306`.
- Active application database: `aalmari_shopping`; do not create or switch to an empty `aalmari` database.
- The original database contains 14 active seller products and 3 existing users.
- Maven verification currently succeeds with `mvnw.cmd test`.
- Homepage and login routes have been verified with HTTP 200 responses.
- The footer is a shared JSP fragment and must not contain nested `<html>`, `<head>`, or `<body>` tags.
- Footer styling is centralized in `static/css/footer.css` and applies across JSP pages.
- Profile photos use `S3Service.generateProfilePicUrl()` for private buckets. Valid AWS credentials and `GetObject` permission are required.
- Direct public S3 profile URLs return `403` for private objects; use presigned URLs rather than exposing bucket objects publicly.
- A local default avatar exists at `static/images/default-avatar.svg` and is used when profile image keys are missing or invalid.
- Login emails are normalized with trimming and lowercase matching.
- The profile route supports `?tab=orders`, `?tab=wishlist`, and `?tab=settings` for footer/profile navigation.

## AWS Security

The previously shared AWS access key was exposed in chat and must be revoked in AWS IAM immediately. Configure only a replacement least-privilege key through environment variables. Do not store AWS secrets in `application.properties`, Java source, README files, Git, or screenshots.