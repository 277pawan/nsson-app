# API-Responsive Product Architecture

## Overview
The app now automatically fetches real product data from the Garage Admin Backend API on every startup. Products are NO LONGER hardcoded - they're dynamically fetched and updated in real-time.

## Architecture

### 1. Product Provider (`lib/providers/product_provider.dart`)
**Role**: State management for products, brands, categories, and banners
**Key Features**:
- Fetches data from API on app initialization via `loadAll()`
- Prioritizes API data, falls back to DummyData only if API fails
- Tracks initialization state: `isInitialized` and `isInitFromApiSuccessful`
- Provides `refreshAll()` for pull-to-refresh functionality

**Methods**:
```dart
loadAll()          // Called once on app startup - fetches all data from API
refreshAll()       // Manual refresh (pull-to-refresh in UI)
fetchProducts()    // Fetch products (with optional category/brand filters)
fetchBrands()      // Fetch all brands from API
fetchCategories()  // Fetch all categories from API
fetchBanners()     // Fetch promotional banners
```

### 2. Product Repository (`lib/data/repositories/product_repository.dart`)
**Role**: Clean API calls layer (optional, for future use)
**Benefits**:
- Separates API logic from state management
- Easy to mock for testing
- Reusable across different features
- Single source of truth for API endpoints

### 3. API Service (`lib/core/services/api_service.dart`)
**Role**: Low-level HTTP client
- Handles authentication tokens
- Resolves image URLs
- Manages request/response headers
- Base URL: `http://10.0.2.2:8080/api` (Android) / `http://localhost:8080/api` (iOS)

---

## Data Flow

```
App Startup
    ↓
_AuthGate.initState() 
    ↓
ProductProvider.loadAll()
    ↓
    ├─ fetchProducts()  → GET /api/products
    ├─ fetchBrands()    → GET /api/brands
    ├─ fetchCategories()→ GET /api/categories
    └─ fetchBanners()   → GET /api/banners?live=true
    ↓
If API success: Use real data from backend
If API fails:   Fall back to DummyData (for offline support)
    ↓
UI Screens watch ProductProvider and display data
    ↓
User pulls-to-refresh → refreshAll() → fetches fresh data
```

---

## Screens Using API Data

### ✅ HomeScreen
- Automatically loads all products, brands, categories, banners on init
- Displays fetched data
- Pull-to-refresh calls `refreshAll()`
- Falls back to dummy data if API is down

### ✅ CategoriesScreen
- Displays categories from ProductProvider
- Filters products by category when user taps

### ✅ ProductListingScreen
- Fetches products on init with optional category/brand filters
- Search functionality works on fetched data
- Real-time product discovery

### ✅ ProductDetailScreen
- Can fetch individual product details via `fetchProductById()`
- Shows real price, stock, description from backend

---

## Key Features

### 1. **Automatic Product Updates**
When admin adds a new product to the backend:
- User won't see it immediately (API cache) but after:
  - App restart, OR
  - Pull-to-refresh on home screen, OR
  - Navigate back to home screen

### 2. **Smart Fallback**
- If API is down: DummyData is used (offline support)
- If API has no products: DummyData is used (graceful degradation)
- If API returns products: Real data is used (preferred)

### 3. **Real-time Prices**
Product prices calculated from API:
```dart
finalPrice = price - (price * discount / 100)
```

### 4. **Stock Status**
- Real stock count from backend
- Out-of-stock products can be filtered
- Low-stock indicators for inventory management

### 5. **Image Handling**
- Images resolved via `ApiService.resolveImageUrl()`
- Cloudinary/ImageKit URL resolution
- Cached network images for performance

---

## Configuration

### Backend Base URL
Default (Android Emulator):
```dart
http://10.0.2.2:8080/api
```

Physical Device/Wi-Fi:
```dart
http://<YOUR_MACHINE_IP>:8080/api
```

iOS Simulator:
```dart
http://localhost:8080/api
```

Can be configured via environment variable:
```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.com/api
```

---

## API Response Format

### Products
```json
{
  "success": true,
  "products": [
    {
      "_id": "prod_123",
      "name": "Brake Pad",
      "partNumber": "BP-001",
      "brand": "Hero",
      "category": "Braking System",
      "price": 500,
      "discount": 10,
      "stock": 150,
      "image": "https://...",
      "images": ["https://..."],
      "description": "...",
      "warrantyMonths": 12
    }
  ],
  "total": 45
}
```

### Brands
```json
{
  "success": true,
  "brands": [
    {
      "_id": "brand_1",
      "name": "Hero",
      "logo": "https://..."
    }
  ]
}
```

### Categories
```json
{
  "categories": [
    {
      "_id": "cat_1",
      "name": "Braking System",
      "description": "..."
    }
  ]
}
```

### Banners
```json
{
  "success": true,
  "data": [
    {
      "_id": "banner_1",
      "title": "Summer Sale",
      "image": "https://...",
      "isLive": true
    }
  ]
}
```

---

## Error Handling

### Network Errors
- User sees loading state
- Falls back to DummyData
- Error message in provider's `error` field

### Empty API Response
- Falls back to DummyData for continuity
- No error shown to user (graceful)

### Malformed Data
- Individual items skipped by `map().toList()` filter
- Valid items shown, invalid items ignored

---

## Testing

### Test Real API Connection
1. Start backend: `cd Garage_admin_backend-master/backend && npm run dev`
2. Run app: `flutter run`
3. Check home screen - should show real products
4. Pull-to-refresh to verify fresh data fetch

### Test Offline Fallback
1. Stop backend
2. Kill app and re-run
3. DummyData should be displayed
4. No crash or blank screen

### Monitor API Calls
Enable debug logging in ApiService:
```dart
print('[ApiService][GET] $url');
```

---

## Future Enhancements

### 1. Implement ProductRepository
Currently created but not used. Can integrate for better testing:
```dart
class ProductProvider {
  final ProductRepository _repo = ProductRepository();
  
  Future<void> fetchProducts() async {
    _products = await _repo.fetchProducts();
  }
}
```

### 2. Add Infinite Scroll/Pagination
Use `page` parameter:
```dart
await _repo.fetchProducts(page: 2, limit: 20);
```

### 3. Implement Search
```dart
final results = await _repo.searchProducts('brake pad');
```

### 4. Cache Products Locally
```dart
// Store products in Hive/SQLite for offline access
```

### 5. Real-time Updates
```dart
// Use WebSockets for live product updates
```

---

## Troubleshooting

### Problem: Blank screen / No products showing
**Solution**: 
1. Check backend is running on port 8080
2. Verify API URL in ApiService matches your setup
3. Check network connectivity

### Problem: Products from DummyData instead of API
**Solution**:
1. Backend might be down or not returning products
2. Check API response in debug console
3. Verify product structure matches models

### Problem: Old products still showing
**Solution**:
1. App caches data - restart app
2. Or pull-to-refresh on home screen
3. Or wait for WebSocket updates (future)

---

## File Structure

```
lib/
├── providers/
│   └── product_provider.dart       # State management (API calls)
├── data/
│   ├── models.dart                 # Product, Brand, Category models
│   ├── dummy_data.dart             # Fallback data (no longer primary)
│   └── repositories/
│       └── product_repository.dart # API layer (optional, for future)
└── core/services/
    └── api_service.dart            # HTTP client
```

---

## Benefits of This Architecture

✅ **Dynamic Product Management**: Admin adds products → Auto-appears in app  
✅ **Real-time Data**: Always fetches fresh data on startup  
✅ **Offline Support**: Falls back gracefully if API is down  
✅ **Scalable**: Easy to add more endpoints via ProductRepository  
✅ **Testable**: API layer separated from UI  
✅ **Maintainable**: DummyData as fallback, not primary  
✅ **User-friendly**: No need to hardcode or rebuild app for changes  

---

## Admin Workflow

1. Admin adds new product via Garage Admin dashboard
2. Connect app to backend via API
3. App automatically fetches new product
4. User sees new product in:
   - Home screen (after restart/refresh)
   - Categories screen
   - Search results
   - Products listing

**No code changes needed!**

